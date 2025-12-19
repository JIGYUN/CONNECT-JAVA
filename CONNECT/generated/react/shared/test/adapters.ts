// filepath: src/shared/test/adapters.ts
import type { TestEntry } from '@/shared/test/types';

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
export function adaptInTest(row: unknown): TestEntry {
    const o = unwrapRow(row);
    const idField = pickNum(o, ["TEST_IDX","testIdx","id","ID"]);
    const titleField = pickStr(o, ["TITLE","title"]);
    const contentField = pickNum(o, ["CONTENT","content"]);
    const createdByField = pickStr(o, ["CREATED_BY","createdBy"]);
    const createdDtField = pickStr(o, ["CREATED_DT","createdDt"]);
    const updatedByField = pickStr(o, ["UPDATED_BY","updatedBy"]);
    const updatedDtField = pickStr(o, ["UPDATED_DT","updatedDt"]);
    const useAtField = pickStr(o, ["USE_AT","useAt"]);
    const delYnField = pickStr(o, ["DEL_YN","delYn"]);

    return {
        id: idField ?? null,
        title: titleField ?? null,
        content: contentField ?? null,
        createdBy: createdByField ?? null,
        createdDt: createdDtField ?? null,
        updatedBy: updatedByField ?? null,
        updatedDt: updatedDtField ?? null,
        useAt: useAtField ?? null,
        delYn: delYnField ?? null,
    };
}

/** 프런트 → 서버 (업서트/전송용) */
export function adaptOutTest(input: TestEntry): Record<string, unknown> {
    return {
        TEST_IDX: input.id ?? null,
        TITLE: input.title ?? null,
        CONTENT: input.content ?? null,
        CREATED_BY: input.createdBy ?? null,
        CREATED_DT: input.createdDt ?? null,
        UPDATED_BY: input.updatedBy ?? null,
        UPDATED_DT: input.updatedDt ?? null,
        USE_AT: input.useAt ?? null,
        DEL_YN: input.delYn ?? null,
    };
}
