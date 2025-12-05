// filepath: src/shared/payment/types.ts
import type { Id } from '@/shared/types/common';

/**
 * PaymentEntry
 * - DB 테이블 TB_PAYMENT 기반 자동생성
 * - PK: PAYMENT_ID
 */
export type PaymentEntry = {
    id?: Id | null;
    orderId?: number | null;
    pgCd?: string | null;
    pgMid?: string | null;
    pgTid?: string | null;
    payMethodCd?: string | null;
    payTotalAmt?: string | null;
    payApprovedAmt?: string | null;
    payStatusCd?: string | null;
    reqDt?: string | null;
    resDt?: string | null;
    rawRequestJson?: string | null;
    rawResponseJson?: string | null;
    useAt?: string | null;
    createdDt?: string | null;
    createdBy?: number | null;
    updatedDt?: string | null;
    updatedBy?: number | null;
};

/**
 * PaymentUpsertInput
 * - 업서트 API 파라미터 표준
 */
export type PaymentUpsertInput = {
    diaryDt: string;
    content: string;
    grpCd?: string | null;
    ownerId?: Id | null;
};
