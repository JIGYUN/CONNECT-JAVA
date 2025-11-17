// filepath: src/shared/chatMessage/types.ts
import type { Id } from '@/shared/types/common';

/**
 * ChatMessageEntry
 * - DB 테이블 TB_CHAT_MESSAGE 기반 자동생성
 * - PK: MSG_ID
 */
export type ChatMessageEntry = {
    id?: Id | null;
    roomId?: number | null;
    senderId?: number | null;
    senderNm?: string | null;
    content?: string | null;
    contentType?: string | null;
    sentDt?: string | null;
    readCnt?: number | null;
    useAt?: string | null;
    createdDt?: string | null;
    createdBy?: number | null;
    updatedDt?: string | null;
    updatedBy?: number | null;
};

/**
 * ChatMessageUpsertInput
 * - 업서트 API 파라미터 표준
 */
export type ChatMessageUpsertInput = {
    diaryDt: string;
    content: string;
    grpCd?: string | null;
    ownerId?: Id | null;
};
