// filepath: src/shared/reservation/types.ts
import type { Id } from '@/shared/types/common';

/**
 * ReservationEntry
 * - DB 테이블 TB_RESERVATION 기반 자동생성
 * - PK: RESERVATION_ID
 */
export type ReservationEntry = {
    reservationId?: Id | null;
    grpCd?: string | null;
    ownerId?: number | null;
    title?: string | null;
    content?: string | null;
    resourceNm?: string | null;
    capacityCnt?: number | null;
    resvStartDt?: string | null;
    resvEndDt?: string | null;
    statusCd?: string | null;
    alertBeforeMin?: number | null;
    useAt?: string | null;
    createdDt?: string | null;
    createdBy?: number | null;
    updatedDt?: string | null;
    updatedBy?: number | null;
};

/**
 * ReservationUpsertInput
 * - 업서트 API 파라미터 표준
 */
export type ReservationUpsertInput = {
    diaryDt: string;
    content: string;
    grpCd?: string | null;
    ownerId?: Id | null;
};
