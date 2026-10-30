from abc import ABC, abstractmethod
from .dfg_creator import BaseNode, OperatorNode, IdentifierNode, OP_TYPES
from typing import List, Dict, Set


class ScheduledNodeInfo:
    def __init__(self, node: OperatorNode, scheduled_time: int, resource_num: int):
        self.node = node
        self.scheduled_time = scheduled_time
        self.resource_num = resource_num


class ListScheduler(ABC):
    def __init__(self, dfg_root: BaseNode, numof_reources: dict):
        self.root = dfg_root
        if numof_reources is None:
            self.numof_resources = {op: 1 for op in OP_TYPES}
        else:
            self.numof_resources = numof_reources

        self.scheduled_nodes_info: List[ScheduledNodeInfo] = []
        self._all_ops: List[OperatorNode] = self._collect_operator_nodes(self.root)
        self._cur_time: int = 1

    def _collect_operator_nodes(self, node: BaseNode) -> List[OperatorNode]:
        ops: List[OperatorNode] = []
        stack = [node]
        seen: Set[int] = set()
        while stack:
            n = stack.pop()
            if n is None:
                continue
            if n.id in seen:
                continue
            seen.add(n.id)

            if isinstance(n, OperatorNode):
                ops.append(n)
                for ch in n.operands:
                    if ch is not None:
                        stack.append(ch)
            elif isinstance(n, IdentifierNode):
                continue
            else:
                continue
        return ops

    def _scheduled_time_map(self) -> Dict[int, int]:
        return {info.node.id: info.scheduled_time for info in self.scheduled_nodes_info}

    def _is_scheduled(self, node: OperatorNode) -> bool:
        return any(info.node.id == node.id for info in self.scheduled_nodes_info)

    def record_scheduled_node(self, node: OperatorNode, scheduled_time: int, resource_num: int):
        recorded_info = ScheduledNodeInfo(node=node, scheduled_time=scheduled_time, resource_num=resource_num)
        self.scheduled_nodes_info.append(recorded_info)

    def get_scheduling_info(self) -> List[ScheduledNodeInfo]:
        return sorted(self.scheduled_nodes_info, key=lambda node_info: node_info.node.id)

    @abstractmethod
    def find_candidate_nodes(self) -> List[OperatorNode]:
        pass

    @abstractmethod
    def select_from_frontier(self, frontier: dict) -> List[OperatorNode]:
        pass

    @abstractmethod
    def schedule(self) -> None:
        pass


class MinLatencyScheduler(ListScheduler):
    def __init__(self, dfg_root: BaseNode, numof_resources: dict):
        super().__init__(dfg_root=dfg_root, numof_reources=numof_resources)

    def find_candidate_nodes(self) -> List[OperatorNode]:
        sched_map = self._scheduled_time_map()
        cur = self._cur_time

        candidates: List[OperatorNode] = []
        for op in self._all_ops:
            if op.id in sched_map:
                continue

            ready = True
            for operand in op.operands:
                if isinstance(operand, OperatorNode):
                    if operand.id not in sched_map or sched_map[operand.id] >= cur:
                        ready = False
                        break
            if ready:
                candidates.append(op)

        return candidates

    def select_from_frontier(self, frontier: dict) -> List[OperatorNode]:
        selected: List[OperatorNode] = []

        for t in OP_TYPES:
            nodes = frontier.get(t, [])
            nodes_sorted = sorted(nodes, key=lambda n: (-n.depth, n.id))

            limit = int(self.numof_resources.get(t, 1))
            selected.extend(nodes_sorted[:limit])

        return selected

    def schedule(self) -> None:
        cur = 1
        total_ops = len(self._all_ops)

        while len(self.scheduled_nodes_info) < total_ops:
            self._cur_time = cur

            candidates = self.find_candidate_nodes()
            frontier: Dict[str, List[OperatorNode]] = {t: [] for t in OP_TYPES}
            for n in candidates:
                frontier[n.op_type].append(n)

            chosen = self.select_from_frontier(frontier)
            used_count: Dict[str, int] = {t: 0 for t in OP_TYPES}
            for node in chosen:
                rnum = used_count[node.op_type] +1
                used_count[node.op_type] += 1
                self.record_scheduled_node(node=node, scheduled_time=cur, resource_num=rnum)

            cur += 1


class MinResourceScheduler(ListScheduler):
    def __init__(self, dfg_root: BaseNode, numof_resources: dict, max_time: int):
        super().__init__(dfg_root=dfg_root, numof_reources=numof_resources)
        self.max_time = max_time
        self.latest_time = self.find_latest_times()

    def find_latest_times(self) -> dict:
        parents: Dict[int, List[OperatorNode]] = {op.id: [] for op in self._all_ops}
        stack = [self.root]
        seen: Set[int] = set()
        while stack:
            n = stack.pop()
            if n is None or n.id in seen:
                continue
            seen.add(n.id)

            if isinstance(n, OperatorNode):
                for ch in n.operands:
                    if isinstance(ch, OperatorNode):
                        parents[ch.id].append(n)
                        stack.append(ch)
                    elif isinstance(ch, IdentifierNode):
                        continue
        memo: Dict[int, int] = {}

        def compute_latest(op: OperatorNode) -> int:
            if op.id in memo:
                return memo[op.id]

            if op.id == self.root.id:
                memo[op.id] = self.max_time
                return memo[op.id]

            if not parents[op.id]:
                memo[op.id] = self.max_time
                return memo[op.id]

            val = min(compute_latest(p) - 1 for p in parents[op.id])
            memo[op.id] = val
            return val

        latest_time: Dict[int, int] = {}
        for op in self._all_ops:
            latest_time[op.id] = compute_latest(op)

        return latest_time

    def find_candidate_nodes(self) -> List[OperatorNode]:
        sched_map = self._scheduled_time_map()
        cur = self._cur_time

        candidates: List[OperatorNode] = []
        for op in self._all_ops:
            if op.id in sched_map:
                continue

            ready = True
            for operand in op.operands:
                if isinstance(operand, OperatorNode):
                    if operand.id not in sched_map or sched_map[operand.id] >= cur:
                        ready = False
                        break
            if ready:
                candidates.append(op)

        return candidates

    def select_from_frontier(self, frontier: dict) -> List[OperatorNode]:
        cur = self._cur_time
        selected: List[OperatorNode] = []

        must: Dict[str, List[OperatorNode]] = {t: [] for t in OP_TYPES}
        optional: Dict[str, List[OperatorNode]] = {t: [] for t in OP_TYPES}

        for t in OP_TYPES:
            for n in frontier.get(t, []):
                slack = self.latest_time[n.id] - cur
                if slack <= 0:
                    must[t].append(n)
                else:
                    optional[t].append(n)

        for t in OP_TYPES:
            if len(must[t]) > self.numof_resources.get(t, 1):
                self.numof_resources[t] = len(must[t])

        for t in OP_TYPES:
            must_sorted = sorted(must[t], key=lambda n: (-n.depth, n.id), reverse=True)
            selected.extend(must_sorted)

        for t in OP_TYPES:
            limit = int(self.numof_resources.get(t, 1))
            already = len(must[t])
            remaining = max(0, limit - already)

            if remaining == 0:
                continue

            opt_sorted = sorted(
                optional[t],
                key=lambda n: (self.latest_time[n.id] - cur, -n.depth, n.id)
            )
            selected.extend(opt_sorted[:remaining])

        return selected

    def schedule(self) -> None:
        cur = 1
        total_ops = len(self._all_ops)

        while len(self.scheduled_nodes_info) < total_ops and cur <= self.max_time:
            self._cur_time = cur

            candidates = self.find_candidate_nodes()
            frontier: Dict[str, List[OperatorNode]] = {t: [] for t in OP_TYPES}
            for n in candidates:
                frontier[n.op_type].append(n)

            chosen = self.select_from_frontier(frontier)

            used_count: Dict[str, int] = {t: 0 for t in OP_TYPES}
            for node in chosen:
                if any(info.node.id == node.id for info in self.scheduled_nodes_info):
                    continue
                rnum = used_count[node.op_type] + 1
                used_count[node.op_type] += 1
                self.record_scheduled_node(node=node, scheduled_time=cur, resource_num=rnum)

            cur += 1

        if len(self.scheduled_nodes_info) < total_ops:
            raise RuntimeError("Could not schedule all operations within MaxTime (infeasible constraint).")
