// filepath: src/shared/chatRoom/types.ts
import type { Id } from '@/shared/types/common';

/**
 * ChatRoomEntry
 * - DB 테이블 TB_CHAT_ROOM 기반 자동생성
 * - PK: ROOM_ID
 */
export type ChatRoomEntry = {
    id?: Id | null;
    grpCd?: string | null;
    ownerId?: number | null;
    roomNm?: string | null;
    roomType?: string | null;
    roomDesc?: string | null;
    lastMsgContent?: string | null;
    lastMsgSentDt?: string | null;
    useAt?: string | null;
    createdDt?: string | null;
    createdBy?: number | null;
    updatedDt?: string | null;
    updatedBy?: number | null;
};

/**
 * ChatRoomUpsertInput
 * - 업서트 API 파라미터 표준
 */
export type ChatRoomUpsertInput = {
    diaryDt: string;
    content: string;
    grpCd?: string | null;
    ownerId?: Id | null;
};
