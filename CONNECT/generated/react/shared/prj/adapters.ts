// filepath: src/shared/prj/adapters.ts
import type { prjEntry } from '@/shared/prj/types';

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
export function adaptInprj(row: unknown): prjEntry {
    const o = unwrapRow(row);
    const idField = pickNum(o, ["PRJ_ID","prjId","id","ID"]);
    const grpCdField = pickStr(o, ["GRP_CD","grpCd"]);
    const prjKeyField = pickStr(o, ["PRJ_KEY","prjKey"]);
    const prjNmField = pickStr(o, ["PRJ_NM","prjNm"]);
    const prjDescField = pickStr(o, ["PRJ_DESC","prjDesc"]);
    const statusCdField = pickStr(o, ["STATUS_CD","statusCd"]);
    const colorCdField = pickStr(o, ["COLOR_CD","colorCd"]);
    const createdDtField = pickStr(o, ["CREATED_DT","createdDt"]);
    const createdByField = pickStr(o, ["CREATED_BY","createdBy"]);
    const updatedDtField = pickStr(o, ["UPDATED_DT","updatedDt"]);
    const updatedByField = pickStr(o, ["UPDATED_BY","updatedBy"]);
    const useAtField = pickStr(o, ["USE_AT","useAt"]);

    return {
        id: idField ?? null,
        grpCd: grpCdField ?? null,
        prjKey: prjKeyField ?? null,
        prjNm: prjNmField ?? null,
        prjDesc: prjDescField ?? null,
        statusCd: statusCdField ?? null,
        colorCd: colorCdField ?? null,
        createdDt: createdDtField ?? null,
        createdBy: createdByField ?? null,
        updatedDt: updatedDtField ?? null,
        updatedBy: updatedByField ?? null,
        useAt: useAtField ?? null,
    };
}

/** 프런트 → 서버 (업서트/전송용) */
export function adaptOutprj(input: prjEntry): Record<string, unknown> {
    return {
        PRJ_ID: input.id ?? null,
        GRP_CD: input.grpCd ?? null,
        PRJ_KEY: input.prjKey ?? null,
        PRJ_NM: input.prjNm ?? null,
        PRJ_DESC: input.prjDesc ?? null,
        STATUS_CD: input.statusCd ?? null,
        COLOR_CD: input.colorCd ?? null,
        CREATED_DT: input.createdDt ?? null,
        CREATED_BY: input.createdBy ?? null,
        UPDATED_DT: input.updatedDt ?? null,
        UPDATED_BY: input.updatedBy ?? null,
        USE_AT: input.useAt ?? null,
    };
}
