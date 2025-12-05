// filepath: src/shared/pointLedger/types.ts
import type { Id } from '@/shared/types/common';

/**
 * PointLedgerEntry
 * - DB 테이블 TB_POINT_LEDGER 기반 자동생성
 * - PK: POINT_LEDGER_ID
 */
export type PointLedgerEntry = {
    id?: Id | null;
    userId?: number | null;
    orderId?: number | null;
    typeCd?: string | null;
    amt?: string | null;
    balanceAfter?: string | null;
    memo?: string | null;
    createdDt?: string | null;
    createdBy?: number | null;
    updatedDt?: string | null;
    updatedBy?: number | null;
};

/**
 * PointLedgerUpsertInput
 * - 업서트 API 파라미터 표준
 */
export type PointLedgerUpsertInput = {
    diaryDt: string;
    content: string;
    grpCd?: string | null;
    ownerId?: Id | null;
};
