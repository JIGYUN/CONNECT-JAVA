// filepath: src/shared/issue/adapters.ts
import type { IssueEntry } from '@/shared/issue/types';

const isRec = (v: unknown): v is Record<string, unknown> =>
    typeof v === 'object' && v !== null;

function pickStr(o: Record<string, unknown>, keys: string[]): string | null {
    for (const k of keys) {
        const v = o[k];
        if (typeof v === 'string' && v.trim() !== '') return v;
    }
    return null;
}

function pickNum(o: Record<String, unknown>, keys: string[]): number | null {
    for (const k of keys) {
        const v = o[k];
        if (typeof v === 'number' && Number.isFinite(v)) return v;
        if (typeof v === 'string') {
            const n = Number(v);
            if (Number.isFinite(n)) return n;
        }
    }
    return null;
}

/** result/data/item 래핑을 최대 5단계 언랩 */
function unwrapRow(row: unknown): Record<string, unknown> {
    let cur: unknown = row;
    for (let i = 0; i < 5; i++) {
        if (!isRec(cur)) break;
        const next =
            (isRec(cur['result']) && cur['result']) ||
            (isRec(cur['data']) && cur['data'])   ||
            (isRec(cur['item']) && cur['item']);
        if (next) {
            cur = next;
            continue;
        }
        break;
    }
    return isRec(cur) ? cur : {};
}

/** 서버 → 프런트 표준화 */
export function adaptInIssue(row: unknown): IssueEntry {
    const o = unwrapRow(row);
    const idField = pickNum(o, ["ISSUE_ID","issueId","id","ID"]);
    const grpCdField = pickStr(o, ["GRP_CD","grpCd"]);
    const prjIdField = pickNum(o, ["PRJ_ID","prjId"]);
    const issueNoField = pickNum(o, ["ISSUE_NO","issueNo"]);
    const issueKeyField = pickStr(o, ["ISSUE_KEY","issueKey"]);
    const issueTypeCdField = pickStr(o, ["ISSUE_TYPE_CD","issueTypeCd"]);
    const summaryField = pickStr(o, ["SUMMARY","summary"]);
    const descriptionField = pickStr(o, ["DESCRIPTION","description"]);
    const priorityCdField = pickStr(o, ["PRIORITY_CD","priorityCd"]);
    const statusCdField = pickStr(o, ["STATUS_CD","statusCd"]);
    const reporterIdField = pickNum(o, ["REPORTER_ID","reporterId"]);
    const assigneeIdField = pickNum(o, ["ASSIGNEE_ID","assigneeId"]);
    const parentIssueIdField = pickNum(o, ["PARENT_ISSUE_ID","parentIssueId"]);
    const startDtField = pickStr(o, ["START_DT","startDt"]);
    const dueDtField = pickStr(o, ["DUE_DT","dueDt"]);
    const estimateMinField = pickNum(o, ["ESTIMATE_MIN","estimateMin"]);
    const spentMinField = pickNum(o, ["SPENT_MIN","spentMin"]);
    const orderInPrjField = pickNum(o, ["ORDER_IN_PRJ","orderInPrj"]);
    const createdDtField = pickStr(o, ["CREATED_DT","createdDt"]);
    const createdByField = pickStr(o, ["CREATED_BY","createdBy"]);
    const updatedDtField = pickStr(o, ["UPDATED_DT","updatedDt"]);
    const updatedByField = pickStr(o, ["UPDATED_BY","updatedBy"]);
    const useAtField = pickStr(o, ["USE_AT","useAt"]);

    return {
        id: idField ?? null,
        grpCd: grpCdField ?? null,
        prjId: prjIdField ?? null,
        issueNo: issueNoField ?? null,
        issueKey: issueKeyField ?? null,
        issueTypeCd: issueTypeCdField ?? null,
        summary: summaryField ?? null,
        description: descriptionField ?? null,
        priorityCd: priorityCdField ?? null,
        statusCd: statusCdField ?? null,
        reporterId: reporterIdField ?? null,
        assigneeId: assigneeIdField ?? null,
        parentIssueId: parentIssueIdField ?? null,
        startDt: startDtField ?? null,
        dueDt: dueDtField ?? null,
        estimateMin: estimateMinField ?? null,
        spentMin: spentMinField ?? null,
        orderInPrj: orderInPrjField ?? null,
        createdDt: createdDtField ?? null,
        createdBy: createdByField ?? null,
        updatedDt: updatedDtField ?? null,
        updatedBy: updatedByField ?? null,
        useAt: useAtField ?? null,
    };
}

/** 프런트 → 서버 (업서트/전송용) */
export function adaptOutIssue(input: IssueEntry): Record<string, unknown> {
    return {
        ISSUE_ID: input.id ?? null,
        GRP_CD: input.grpCd ?? null,
        PRJ_ID: input.prjId ?? null,
        ISSUE_NO: input.issueNo ?? null,
        ISSUE_KEY: input.issueKey ?? null,
        ISSUE_TYPE_CD: input.issueTypeCd ?? null,
        SUMMARY: input.summary ?? null,
        DESCRIPTION: input.description ?? null,
        PRIORITY_CD: input.priorityCd ?? null,
        STATUS_CD: input.statusCd ?? null,
        REPORTER_ID: input.reporterId ?? null,
        ASSIGNEE_ID: input.assigneeId ?? null,
        PARENT_ISSUE_ID: input.parentIssueId ?? null,
        START_DT: input.startDt ?? null,
        DUE_DT: input.dueDt ?? null,
        ESTIMATE_MIN: input.estimateMin ?? null,
        SPENT_MIN: input.spentMin ?? null,
        ORDER_IN_PRJ: input.orderInPrj ?? null,
        CREATED_DT: input.createdDt ?? null,
        CREATED_BY: input.createdBy ?? null,
        UPDATED_DT: input.updatedDt ?? null,
        UPDATED_BY: input.updatedBy ?? null,
        USE_AT: input.useAt ?? null,
    };
}
