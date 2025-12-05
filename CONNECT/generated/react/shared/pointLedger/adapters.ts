// filepath: src/shared/pointLedger/adapters.ts
import type { PointLedgerEntry } from '@/shared/pointLedger/types';

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
export function adaptInPointLedger(row: unknown): PointLedgerEntry {
    const o = unwrapRow(row);
    const idField = pickNum(o, ["POINT_LEDGER_ID","pointLedgerId","id","ID"]);
    const userIdField = pickNum(o, ["USER_ID","userId"]);
    const orderIdField = pickNum(o, ["ORDER_ID","orderId"]);
    const typeCdField = pickStr(o, ["TYPE_CD","typeCd"]);
    const amtField = pickStr(o, ["AMT","amt"]);
    const balanceAfterField = pickStr(o, ["BALANCE_AFTER","balanceAfter"]);
    const memoField = pickStr(o, ["MEMO","memo"]);
    const createdDtField = pickStr(o, ["CREATED_DT","createdDt"]);
    const createdByField = pickNum(o, ["CREATED_BY","createdBy"]);
    const updatedDtField = pickStr(o, ["UPDATED_DT","updatedDt"]);
    const updatedByField = pickNum(o, ["UPDATED_BY","updatedBy"]);

    return {
        id: idField ?? null,
        userId: userIdField ?? null,
        orderId: orderIdField ?? null,
        typeCd: typeCdField ?? null,
        amt: amtField ?? null,
        balanceAfter: balanceAfterField ?? null,
        memo: memoField ?? null,
        createdDt: createdDtField ?? null,
        createdBy: createdByField ?? null,
        updatedDt: updatedDtField ?? null,
        updatedBy: updatedByField ?? null,
    };
}

/** 프런트 → 서버 (업서트/전송용) */
export function adaptOutPointLedger(input: PointLedgerEntry): Record<string, unknown> {
    return {
        POINT_LEDGER_ID: input.id ?? null,
        USER_ID: input.userId ?? null,
        ORDER_ID: input.orderId ?? null,
        TYPE_CD: input.typeCd ?? null,
        AMT: input.amt ?? null,
        BALANCE_AFTER: input.balanceAfter ?? null,
        MEMO: input.memo ?? null,
        CREATED_DT: input.createdDt ?? null,
        CREATED_BY: input.createdBy ?? null,
        UPDATED_DT: input.updatedDt ?? null,
        UPDATED_BY: input.updatedBy ?? null,
    };
}
