// filepath: src/shared/issueComment/adapters.ts
import type { issueCommentEntry } from '@/shared/issueComment/types';

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
export function adaptInissueComment(row: unknown): issueCommentEntry {
    const o = unwrapRow(row);
    const idField = pickNum(o, ["COMMENT_ID","commentId","id","ID"]);
    const grpCdField = pickStr(o, ["GRP_CD","grpCd"]);
    const issueIdField = pickNum(o, ["ISSUE_ID","issueId"]);
    const contentField = pickStr(o, ["CONTENT","content"]);
    const writerIdField = pickNum(o, ["WRITER_ID","writerId"]);
    const createdDtField = pickStr(o, ["CREATED_DT","createdDt"]);
    const createdByField = pickStr(o, ["CREATED_BY","createdBy"]);
    const updatedDtField = pickStr(o, ["UPDATED_DT","updatedDt"]);
    const updatedByField = pickStr(o, ["UPDATED_BY","updatedBy"]);
    const useAtField = pickStr(o, ["USE_AT","useAt"]);

    return {
        id: idField ?? null,
        grpCd: grpCdField ?? null,
        issueId: issueIdField ?? null,
        content: contentField ?? null,
        writerId: writerIdField ?? null,
        createdDt: createdDtField ?? null,
        createdBy: createdByField ?? null,
        updatedDt: updatedDtField ?? null,
        updatedBy: updatedByField ?? null,
        useAt: useAtField ?? null,
    };
}

/** 프런트 → 서버 (업서트/전송용) */
export function adaptOutissueComment(input: issueCommentEntry): Record<string, unknown> {
    return {
        COMMENT_ID: input.id ?? null,
        GRP_CD: input.grpCd ?? null,
        ISSUE_ID: input.issueId ?? null,
        CONTENT: input.content ?? null,
        WRITER_ID: input.writerId ?? null,
        CREATED_DT: input.createdDt ?? null,
        CREATED_BY: input.createdBy ?? null,
        UPDATED_DT: input.updatedDt ?? null,
        UPDATED_BY: input.updatedBy ?? null,
        USE_AT: input.useAt ?? null,
    };
}
