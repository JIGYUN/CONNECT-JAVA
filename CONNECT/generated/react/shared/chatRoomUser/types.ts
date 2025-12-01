// filepath: src/shared/chatRoomUser/types.ts
import type { Id } from '@/shared/types/common';

/**
 * ChatRoomUserEntry
 * - DB 테이블 TB_CHAT_ROOM_USER 기반 자동생성
 * - PK: ROOM_USER_ID
 */
export type ChatRoomUserEntry = {
    id?: Id | null;
    roomId?: number | null;
    userId?: number | null;
    roleCd?: string | null;
    joinDt?: string | null;
    leaveDt?: string | null;
    useAt?: string | null;
    createdDt?: string | null;
    createdBy?: number | null;
    updatedDt?: string | null;
    updatedBy?: number | null;
};

/**
 * ChatRoomUserUpsertInput
 * - 업서트 API 파라미터 표준
 */
export type ChatRoomUserUpsertInput = {
    diaryDt: string;
    content: string;
    grpCd?: string | null;
    ownerId?: Id | null;
};
