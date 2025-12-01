// filepath: src/shared/chatRoomUser/adapters.ts
import type { ChatRoomUserEntry } from '@/shared/chatRoomUser/types';

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
export function adaptInChatRoomUser(row: unknown): ChatRoomUserEntry {
    const o = unwrapRow(row);
    const idField = pickNum(o, ["ROOM_USER_ID","roomUserId","id","ID"]);
    const roomIdField = pickNum(o, ["ROOM_ID","roomId"]);
    const userIdField = pickNum(o, ["USER_ID","userId"]);
    const roleCdField = pickStr(o, ["ROLE_CD","roleCd"]);
    const joinDtField = pickStr(o, ["JOIN_DT","joinDt"]);
    const leaveDtField = pickStr(o, ["LEAVE_DT","leaveDt"]);
    const useAtField = pickStr(o, ["USE_AT","useAt"]);
    const createdDtField = pickStr(o, ["CREATED_DT","createdDt"]);
    const createdByField = pickNum(o, ["CREATED_BY","createdBy"]);
    const updatedDtField = pickStr(o, ["UPDATED_DT","updatedDt"]);
    const updatedByField = pickNum(o, ["UPDATED_BY","updatedBy"]);

    return {
        id: idField ?? null,
        roomId: roomIdField ?? null,
        userId: userIdField ?? null,
        roleCd: roleCdField ?? null,
        joinDt: joinDtField ?? null,
        leaveDt: leaveDtField ?? null,
        useAt: useAtField ?? null,
        createdDt: createdDtField ?? null,
        createdBy: createdByField ?? null,
        updatedDt: updatedDtField ?? null,
        updatedBy: updatedByField ?? null,
    };
}

/** 프런트 → 서버 (업서트/전송용) */
export function adaptOutChatRoomUser(input: ChatRoomUserEntry): Record<string, unknown> {
    return {
        ROOM_USER_ID: input.id ?? null,
        ROOM_ID: input.roomId ?? null,
        USER_ID: input.userId ?? null,
        ROLE_CD: input.roleCd ?? null,
        JOIN_DT: input.joinDt ?? null,
        LEAVE_DT: input.leaveDt ?? null,
        USE_AT: input.useAt ?? null,
        CREATED_DT: input.createdDt ?? null,
        CREATED_BY: input.createdBy ?? null,
        UPDATED_DT: input.updatedDt ?? null,
        UPDATED_BY: input.updatedBy ?? null,
    };
}
