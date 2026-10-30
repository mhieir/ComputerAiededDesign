from __future__ import annotations

import ast
import math
import os
from collections import defaultdict
from dataclasses import dataclass
from typing import Dict, List, DefaultDict, Set, Optional

from .scheduler import ScheduledNodeInfo
from .dfg_creator import OperatorNode, IdentifierNode


@dataclass
class VerilogGenConfig:
    data_width: int = 32


class VerilogGenerator:
    def __init__(self, schedule_info: List[ScheduledNodeInfo], cfg: VerilogGenConfig | None = None):
        if not schedule_info:
            raise ValueError("schedule_info is empty")

        self.cfg = cfg or VerilogGenConfig()
        self.schedule_info = schedule_info

        self.ops: List[OperatorNode] = []
        self.ops_by_id: Dict[int, OperatorNode] = {}
        self.root: Optional[OperatorNode] = None

        self.input_nodes: List[IdentifierNode] = []
        self.input_names: List[str] = []
        self.input_sel_code: Dict[str, int] = {}

        self.reg_name: Dict[int, str] = {}
        self.reg_en_name: Dict[int, str] = {}
        self.op_sel_code: Dict[int, int] = {}

        self.sel_w: int = 1

        self.max_fu: Dict[str, int] = {"ALU": 0, "MUL": 0, "LOG": 0}

        self.cycle_ops: DefaultDict[int, List[ScheduledNodeInfo]] = defaultdict(list)
        self.node_to_sched: Dict[int, ScheduledNodeInfo] = {}

        self.min_cycle: int = 1
        self.max_cycle: int = 1
        self.cycle_shift: int = 0

        self.resource_shift: Dict[str, int] = {"ALU": 0, "MUL": 0, "LOG": 0}

    def write(self, folder_path: str) -> None:
        codes_dir = os.path.join(folder_path, "codes")
        os.makedirs(codes_dir, exist_ok=True)

        self.prepare()

        controller_v = self.generate_controller()
        datapath_v = self.generate_datapath()
        top_v = self.generate_top()
        tb_v = self.generate_testbench()

        with open(os.path.join(codes_dir, "my_controller.v"), "w") as f:
            f.write(controller_v)
        with open(os.path.join(codes_dir, "my_datapath.v"), "w") as f:
            f.write(datapath_v)
        with open(os.path.join(codes_dir, "my_top.v"), "w") as f:
            f.write(top_v)
        with open(os.path.join(codes_dir, "tb.v"), "w") as f:
            f.write(tb_v)

    def prepare(self) -> None:
        self._collect_ops()
        self._find_root()
        self._collect_inputs()
        self._normalize_cycles()
        self._normalize_resource_nums()
        self._build_reg_maps()
        self._compute_sel_width()
        self._compute_fu_instances()
        self._build_schedule_tables()

    def _collect_ops(self) -> None:
        self.ops = [ni.node for ni in self.schedule_info]
        self.ops_by_id = {n.id: n for n in self.ops}

    def _find_root(self) -> None:
        used_as_operand: Set[int] = set()
        for n in self.ops:
            for opnd in n.operands:
                if isinstance(opnd, OperatorNode):
                    used_as_operand.add(opnd.id)

        roots = [n for n in self.ops if n.id not in used_as_operand]
        if len(roots) == 1:
            self.root = roots[0]
        else:
            self.root = max(self.schedule_info, key=lambda x: (x.scheduled_time, x.node.id)).node

    def _collect_inputs(self) -> None:
        id_nodes: Dict[int, IdentifierNode] = {}

        def walk(node):
            if isinstance(node, IdentifierNode):
                id_nodes[node.id] = node
            elif isinstance(node, OperatorNode):
                for ch in node.operands:
                    walk(ch)

        for n in self.ops:
            walk(n)

        self.input_nodes = [id_nodes[k] for k in sorted(id_nodes.keys())]
        self.input_names = [n.name for n in self.input_nodes]
        self.input_sel_code = {name: i for i, name in enumerate(self.input_names)}

    def _normalize_cycles(self) -> None:
        times = [ni.scheduled_time for ni in self.schedule_info]
        self.min_cycle = min(times)
        self.max_cycle = max(times)
        self.cycle_shift = 1 - self.min_cycle

    def _normalize_resource_nums(self) -> None:
        mins = {"ALU": None, "MUL": None, "LOG": None}
        for ni in self.schedule_info:
            t = ni.node.op_type
            mins[t] = ni.resource_num if mins[t] is None else min(mins[t], ni.resource_num)

        for t in ["ALU", "MUL", "LOG"]:
            if mins[t] is None:
                self.resource_shift[t] = 0
            else:
                self.resource_shift[t] = 1 - mins[t]

    def _build_reg_maps(self) -> None:
        self.reg_name.clear()
        self.reg_en_name.clear()

        for node_id in sorted(self.ops_by_id.keys()):
            rn = f"reg_node{node_id}"
            self.reg_name[node_id] = rn
            self.reg_en_name[node_id] = f"{rn}_en"

    def _compute_sel_width(self) -> None:
        num_sources = len(self.input_names) + len(self.ops_by_id)
        if num_sources <= 1:
            self.sel_w = 1
        else:
            self.sel_w = max(1, math.ceil(math.log2(num_sources)))

        base = len(self.input_names)
        self.op_sel_code.clear()
        for idx, node_id in enumerate(sorted(self.ops_by_id.keys())):
            self.op_sel_code[node_id] = base + idx

    def _compute_fu_instances(self) -> None:
        self.max_fu = {"ALU": 0, "MUL": 0, "LOG": 0}
        for ni in self.schedule_info:
            t = ni.node.op_type
            inst = ni.resource_num + self.resource_shift[t]
            self.max_fu[t] = max(self.max_fu[t], inst)

    def _build_schedule_tables(self) -> None:
        self.cycle_ops = defaultdict(list)
        self.node_to_sched.clear()

        for ni in self.schedule_info:
            t = ni.node.op_type
            ni.scheduled_time = ni.scheduled_time + self.cycle_shift
            ni.resource_num = ni.resource_num + self.resource_shift[t]

            self.cycle_ops[ni.scheduled_time].append(ni)
            self.node_to_sched[ni.node.id] = ni

        self.max_cycle = max(self.cycle_ops.keys()) if self.cycle_ops else 1

    def operand_sel(self, opnd) -> int:
        if isinstance(opnd, IdentifierNode):
            return self.input_sel_code[opnd.name]
        if isinstance(opnd, OperatorNode):
            return self.op_sel_code[opnd.id]
        raise RuntimeError("Unsupported operand node type")

    def alu_opcode(self, opnode: OperatorNode) -> str:
        if isinstance(opnode.op, ast.Add):
            return "1'b0"
        if isinstance(opnode.op, ast.Sub):
            return "1'b1"
        return "1'b0"

    def mul_opcode(self, opnode: OperatorNode) -> str:
        if isinstance(opnode.op, ast.Mult):
            return "2'b00"
        if isinstance(opnode.op, ast.Div):
            return "2'b01"
        if isinstance(opnode.op, ast.Mod):
            return "2'b10"
        return "2'b00"

    def log_opcode(self, opnode: OperatorNode) -> str:
        if isinstance(opnode.op, ast.BitAnd):
            return "2'b00"
        if isinstance(opnode.op, ast.BitOr):
            return "2'b01"
        if isinstance(opnode.op, ast.BitXor):
            return "2'b10"
        return "2'b00"

    def generate_controller(self) -> str:
        SEL_W = self.sel_w

        ports: List[str] = [
            "input clk, rst, start",
            "output reg op_ready",
        ]

        for t in ["ALU", "LOG", "MUL"]:
            for k in range(1, self.max_fu[t] + 1):
                ports.append(f"output reg [{SEL_W-1}:0] {t.lower()}{k}_sel1, {t.lower()}{k}_sel2")
        for k in range(1, self.max_fu["ALU"] + 1):
            ports.append(f"output reg alu{k}_op")
        for k in range(1, self.max_fu["LOG"] + 1):
            ports.append(f"output reg [1:0] log{k}_op")
        for k in range(1, self.max_fu["MUL"] + 1):
            ports.append(f"output reg [1:0] mul{k}_op")

        ports += [
            "output reg done_next, result_en",
        ]

        for node_id in sorted(self.ops_by_id.keys()):
            ports.append(f"output reg {self.reg_en_name[node_id]}")

        lines: List[str] = []
        lines.append("module controller(")
        lines.append("  " + ",\n  ".join(ports))
        lines.append(");")
        lines.append("")

        num_states = self.max_cycle + 2
        state_bits = max(1, math.ceil(math.log2(num_states)))
        lines.append(f"reg [{state_bits-1}:0] state, next_state;")
        lines.append("localparam S_IDLE = 0;")
        for c in range(1, self.max_cycle + 1):
            lines.append(f"localparam S_CYCLE_{c} = {c};")
        lines.append(f"localparam S_DONE = {self.max_cycle + 1};")
        lines.append("")
        lines.append("always @(posedge clk or posedge rst) begin")
        lines.append("  if (rst) state <= S_IDLE;")
        lines.append("  else state <= next_state;")
        lines.append("end")
        lines.append("")
        lines.append("always @(*) begin")
        lines.append("  op_ready = 1'b0;")
        lines.append("  next_state = state;")
        for t in ["ALU", "LOG", "MUL"]:
            for k in range(1, self.max_fu[t] + 1):
                lines.append(f"  {t.lower()}{k}_sel1 = {SEL_W}'d0;")
                lines.append(f"  {t.lower()}{k}_sel2 = {SEL_W}'d0;")

        for k in range(1, self.max_fu["ALU"] + 1):
            lines.append(f"  alu{k}_op = 1'b0;")
        for k in range(1, self.max_fu["LOG"] + 1):
            lines.append(f"  log{k}_op = 2'b00;")
        for k in range(1, self.max_fu["MUL"] + 1):
            lines.append(f"  mul{k}_op = 2'b00;")

        lines.append("  result_en = 1'b0;")
        lines.append("  done_next = 1'b0;")

        for node_id in sorted(self.ops_by_id.keys()):
            lines.append(f"  {self.reg_en_name[node_id]} = 1'b0;")

        lines.append("")
        lines.append("  case (state)")
        lines.append("    S_IDLE: begin")
        lines.append("      op_ready = 1'b1;")
        lines.append("      if (start) next_state = S_CYCLE_1;")
        lines.append("    end")

        root_sched = self.node_to_sched[self.root.id]
        for c in range(1, self.max_cycle + 1):
            lines.append(f"    S_CYCLE_{c}: begin")

            for ni in self.cycle_ops[c]:
                n = ni.node
                inst = ni.resource_num

                s1 = self.operand_sel(n.operands[0])
                s2 = self.operand_sel(n.operands[1])

                if n.op_type == "ALU":
                    lines.append(f"      alu{inst}_op = {self.alu_opcode(n)};")
                    lines.append(f"      alu{inst}_sel1 = {SEL_W}'d{s1};")
                    lines.append(f"      alu{inst}_sel2 = {SEL_W}'d{s2};")
                elif n.op_type == "MUL":
                    lines.append(f"      mul{inst}_op = {self.mul_opcode(n)};")
                    lines.append(f"      mul{inst}_sel1 = {SEL_W}'d{s1};")
                    lines.append(f"      mul{inst}_sel2 = {SEL_W}'d{s2};")
                else:
                    lines.append(f"      log{inst}_op = {self.log_opcode(n)};")
                    lines.append(f"      log{inst}_sel1 = {SEL_W}'d{s1};")
                    lines.append(f"      log{inst}_sel2 = {SEL_W}'d{s2};")

                lines.append(f"      {self.reg_en_name[n.id]} = 1'b1;")

            if c == root_sched.scheduled_time:
                lines.append("      result_en = 1'b1;")

            if c < self.max_cycle:
                lines.append(f"      next_state = S_CYCLE_{c+1};")
            else:
                lines.append("      next_state = S_DONE;")

            lines.append("    end")

        lines.append("    S_DONE: begin")
        lines.append("      done_next = 1'b1;")
        lines.append("      next_state = S_IDLE;")
        lines.append("    end")
        lines.append("  endcase")
        lines.append("end")
        lines.append("endmodule")

        return "\n".join(lines)

    def generate_datapath(self) -> str:
        SEL_W = self.sel_w
        DW = self.cfg.data_width

        def emit_mux_always(out_reg: str, sel_sig: str) -> List[str]:
            b: List[str] = []
            b.append(f"always @(*) begin")
            b.append(f"  case ({sel_sig})")
            for name, code in self.input_sel_code.items():
                b.append(f"    {SEL_W}'d{code}: {out_reg} = {name};")
            for node_id in sorted(self.ops_by_id.keys()):
                code = self.op_sel_code[node_id]
                b.append(f"    {SEL_W}'d{code}: {out_reg} = {self.reg_name[node_id]};")

            b.append(f"    default: {out_reg} = {DW}'d0;")
            b.append(f"  endcase")
            b.append(f"end")
            return b

        lines: List[str] = []
        lines.append("module datapath(")
        lines.append("  input clk, rst,")
        for name in self.input_names:
            lines.append(f"  input [{DW-1}:0] {name},")
        for t in ["ALU", "LOG", "MUL"]:
            for k in range(1, self.max_fu[t] + 1):
                lines.append(f"  input [{SEL_W-1}:0] {t.lower()}{k}_sel1,")
                lines.append(f"  input [{SEL_W-1}:0] {t.lower()}{k}_sel2,")
        for k in range(1, self.max_fu["ALU"] + 1):
            lines.append(f"  input alu{k}_op,")
        for k in range(1, self.max_fu["LOG"] + 1):
            lines.append(f"  input [1:0] log{k}_op,")
        for k in range(1, self.max_fu["MUL"] + 1):
            lines.append(f"  input [1:0] mul{k}_op,")

        lines.append("  input done_next,")
        lines.append("  input result_en,")
        for node_id in sorted(self.ops_by_id.keys()):
            lines.append(f"  input {self.reg_en_name[node_id]},")

        lines.append(f"  output reg [{DW-1}:0] result,")
        lines.append("  output reg done")
        lines.append(");")
        lines.append("")
        for node_id in sorted(self.ops_by_id.keys()):
            lines.append(f"reg [{DW-1}:0] {self.reg_name[node_id]};")
        lines.append("")
        for k in range(1, self.max_fu["ALU"] + 1):
            lines.append(f"reg [{DW-1}:0] alu{k}_op1_reg;")
            lines.append(f"reg [{DW-1}:0] alu{k}_op2_reg;")
            lines.append("")

            lines += emit_mux_always(f"alu{k}_op1_reg", f"alu{k}_sel1")
            lines.append("")
            lines += emit_mux_always(f"alu{k}_op2_reg", f"alu{k}_sel2")
            lines.append("")

            lines.append(f"wire [{DW-1}:0] alu{k}_op1 = alu{k}_op1_reg;")
            lines.append(f"wire [{DW-1}:0] alu{k}_op2 = alu{k}_op2_reg;")
            lines.append(f"wire [{DW-1}:0] alu{k}_out = (alu{k}_op == 1'b0) ? (alu{k}_op1 + alu{k}_op2) : (alu{k}_op1 - alu{k}_op2);")
            lines.append("")

        for k in range(1, self.max_fu["MUL"] + 1):
            lines.append(f"reg [{DW-1}:0] mul{k}_op1_reg;")
            lines.append(f"reg [{DW-1}:0] mul{k}_op2_reg;")
            lines.append("")

            lines += emit_mux_always(f"mul{k}_op1_reg", f"mul{k}_sel1")
            lines.append("")
            lines += emit_mux_always(f"mul{k}_op2_reg", f"mul{k}_sel2")
            lines.append("")

            lines.append(f"wire [{DW-1}:0] mul{k}_op1 = mul{k}_op1_reg;")
            lines.append(f"wire [{DW-1}:0] mul{k}_op2 = mul{k}_op2_reg;")

            lines.append(
                f"wire [{DW-1}:0] mul{k}_out = (mul{k}_op == 2'b00) ? (mul{k}_op1 * mul{k}_op2) :"
                f" (mul{k}_op == 2'b01) ? (mul{k}_op1 / mul{k}_op2) :"
                f" (mul{k}_op == 2'b10) ? (mul{k}_op1 % mul{k}_op2) : {DW}'d0;"
            )
            lines.append("")

        for k in range(1, self.max_fu["LOG"] + 1):
            lines.append(f"reg [{DW-1}:0] log{k}_op1_reg;")
            lines.append(f"reg [{DW-1}:0] log{k}_op2_reg;")
            lines.append("")

            lines += emit_mux_always(f"log{k}_op1_reg", f"log{k}_sel1")
            lines.append("")
            lines += emit_mux_always(f"log{k}_op2_reg", f"log{k}_sel2")
            lines.append("")

            lines.append(f"wire [{DW-1}:0] log{k}_op1 = log{k}_op1_reg;")
            lines.append(f"wire [{DW-1}:0] log{k}_op2 = log{k}_op2_reg;")

            lines.append(
                f"wire [{DW-1}:0] log{k}_out = (log{k}_op == 2'b00) ? (log{k}_op1 & log{k}_op2) :"
                f" (log{k}_op == 2'b01) ? (log{k}_op1 | log{k}_op2) :"
                f" (log{k}_op == 2'b10) ? (log{k}_op1 ^ log{k}_op2) : {DW}'d0;"
            )
            lines.append("")

        lines.append("always @(posedge clk or posedge rst) begin")
        lines.append("  if (rst) begin")
        for node_id in sorted(self.ops_by_id.keys()):
            lines.append(f"    {self.reg_name[node_id]} <= {DW}'d0;")
        lines.append(f"    result <= {DW}'d0;")
        lines.append("    done <= 1'b0;")
        lines.append("  end else begin")
        lines.append("    done <= done_next;")

        for node_id in sorted(self.ops_by_id.keys()):
            ni = self.node_to_sched[node_id]
            inst = ni.resource_num
            n = self.ops_by_id[node_id]

            if n.op_type == "ALU":
                src = f"alu{inst}_out"
            elif n.op_type == "MUL":
                src = f"mul{inst}_out"
            else:
                src = f"log{inst}_out"

            lines.append(f"    if ({self.reg_en_name[node_id]}) {self.reg_name[node_id]} <= {src};")

        root_sched = self.node_to_sched[self.root.id]
        rinst = root_sched.resource_num
        if self.root.op_type == "ALU":
            rsrc = f"alu{rinst}_out"
        elif self.root.op_type == "MUL":
            rsrc = f"mul{rinst}_out"
        else:
            rsrc = f"log{rinst}_out"

        lines.append(f"    if (result_en) result <= {rsrc};")
        lines.append("  end")
        lines.append("end")
        lines.append("endmodule")

        return "\n".join(lines)

    def generate_top(self) -> str:
        DW = self.cfg.data_width
        SEL_W = self.sel_w

        ports: List[str] = ["input clk", "input rst", "input start"]
        for name in self.input_names:
            ports.append(f"input [{DW-1}:0] {name}")
        ports.append(f"output [{DW-1}:0] result")
        ports.append("output done")

        lines: List[str] = []
        lines.append("module top(")
        lines.append("  " + ",\n  ".join(ports))
        lines.append(");")
        lines.append("")

        lines.append("  wire op_ready;")
        lines.append("  wire done_next;")
        lines.append("  wire result_en;")
        lines.append("")

        for t in ["ALU", "LOG", "MUL"]:
            for k in range(1, self.max_fu[t] + 1):
                lines.append(f"  wire [{SEL_W-1}:0] {t.lower()}{k}_sel1;")
                lines.append(f"  wire [{SEL_W-1}:0] {t.lower()}{k}_sel2;")
        lines.append("")

        for k in range(1, self.max_fu["ALU"] + 1):
            lines.append(f"  wire alu{k}_op;")
        for k in range(1, self.max_fu["LOG"] + 1):
            lines.append(f"  wire [1:0] log{k}_op;")
        for k in range(1, self.max_fu["MUL"] + 1):
            lines.append(f"  wire [1:0] mul{k}_op;")
        lines.append("")

        for node_id in sorted(self.ops_by_id.keys()):
            lines.append(f"  wire {self.reg_en_name[node_id]};")
        lines.append("")

        ctrl_conns: List[str] = []
        ctrl_conns.append("    .clk(clk)")
        ctrl_conns.append("    .rst(rst)")
        ctrl_conns.append("    .start(start)")
        ctrl_conns.append("    .op_ready(op_ready)")

        for t in ["ALU", "LOG", "MUL"]:
            for k in range(1, self.max_fu[t] + 1):
                ctrl_conns.append(f"    .{t.lower()}{k}_sel1({t.lower()}{k}_sel1)")
                ctrl_conns.append(f"    .{t.lower()}{k}_sel2({t.lower()}{k}_sel2)")

        for k in range(1, self.max_fu["ALU"] + 1):
            ctrl_conns.append(f"    .alu{k}_op(alu{k}_op)")
        for k in range(1, self.max_fu["LOG"] + 1):
            ctrl_conns.append(f"    .log{k}_op(log{k}_op)")
        for k in range(1, self.max_fu["MUL"] + 1):
            ctrl_conns.append(f"    .mul{k}_op(mul{k}_op)")

        ctrl_conns.append("    .done_next(done_next)")
        ctrl_conns.append("    .result_en(result_en)")

        for node_id in sorted(self.ops_by_id.keys()):
            en = self.reg_en_name[node_id]
            ctrl_conns.append(f"    .{en}({en})")

        lines.append("  controller u_controller (")
        lines.append(",\n".join(ctrl_conns))
        lines.append("  );")
        lines.append("")
        dp_conns: List[str] = []
        dp_conns.append("    .clk(clk)")
        dp_conns.append("    .rst(rst)")

        for name in self.input_names:
            dp_conns.append(f"    .{name}({name})")

        for t in ["ALU", "LOG", "MUL"]:
            for k in range(1, self.max_fu[t] + 1):
                dp_conns.append(f"    .{t.lower()}{k}_sel1({t.lower()}{k}_sel1)")
                dp_conns.append(f"    .{t.lower()}{k}_sel2({t.lower()}{k}_sel2)")

        for k in range(1, self.max_fu["ALU"] + 1):
            dp_conns.append(f"    .alu{k}_op(alu{k}_op)")
        for k in range(1, self.max_fu["LOG"] + 1):
            dp_conns.append(f"    .log{k}_op(log{k}_op)")
        for k in range(1, self.max_fu["MUL"] + 1):
            dp_conns.append(f"    .mul{k}_op(mul{k}_op)")

        dp_conns.append("    .done_next(done_next)")
        dp_conns.append("    .result_en(result_en)")

        for node_id in sorted(self.ops_by_id.keys()):
            en = self.reg_en_name[node_id]
            dp_conns.append(f"    .{en}({en})")

        dp_conns.append("    .result(result)")
        dp_conns.append("    .done(done)")

        lines.append("  datapath u_datapath (")
        lines.append(",\n".join(dp_conns))
        lines.append("  );")
        lines.append("")
        lines.append("endmodule")

        return "\n".join(lines)

    def generate_testbench(self) -> str:
        DW = self.cfg.data_width
        lines = []
        lines.append("`timescale 1ns/1ns")
        lines.append("module tb;")
        lines.append("  reg clk, rst, start;")
        for name in self.input_names:
            lines.append(f"  reg [{DW-1}:0] {name};")
        lines.append(f"  wire [{DW-1}:0] result;")
        lines.append("  wire done;")
        lines.append("")
        lines.append("  top uut (")
        lines.append("    .clk(clk), .rst(rst), .start(start),")
        for name in self.input_names:
            lines.append(f"    .{name}({name}),")
        lines.append("    .result(result), .done(done)")
        lines.append("  );")
        lines.append("  initial begin")
        lines.append("    clk = 0;")
        lines.append("    forever #5 clk = ~clk;")
        lines.append("  end")
        lines.append("  initial begin")
        lines.append("    rst = 1; start = 0;")
        val = 10
        for name in self.input_names:
            lines.append(f"    {name} = {DW}'d{val};")
            val += 10

        lines.append("    #15 rst = 0;")
        lines.append("    #10 start = 1;")
        lines.append("    #10 start = 0;")
        lines.append("    wait(done == 1);")
        lines.append("    #20;")
        lines.append('    $display("Simulation Finished. Result = %d", result);')
        lines.append("    $stop;")
        lines.append("  end")
        lines.append("endmodule")
        return "\n".join(lines)