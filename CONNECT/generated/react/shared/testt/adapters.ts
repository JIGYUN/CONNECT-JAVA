// filepath: src/shared/testt/adapters.ts
import type { TesttEntry } from '@/shared/testt/types';

const isRec = (v: unknown): v is Record<string, unknown> =>
    typeof v === 'object' && v !== null;

function pickStr(o: Record<string, unknown>, keys: string[]): string | null {
    for (const k of keys) {
        const v = o[k];
        if (typeof v === 'string' && v.trim() !== '') return v;
    }
    return null;
}

function pickNum(o: Record<string, unknown>, keys: string[]): number | null {
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
export function adaptInTestt(row: unknown): TesttEntry {
    const o = unwrapRow(row);
    const idField = pickNum(o, ["TESTT_IDX","testtIdx","id","ID"]);
    const grpCdField = pickStr(o, ["GRP_CD","grpCd"]);
    const boardCdField = pickStr(o, ["BOARD_CD","boardCd"]);
    const categoryCdField = pickStr(o, ["CATEGORY_CD","categoryCd"]);
    const statusCdField = pickStr(o, ["STATUS_CD","statusCd"]);
    const noticeAtField = pickStr(o, ["NOTICE_AT","noticeAt"]);
    const pinAtField = pickStr(o, ["PIN_AT","pinAt"]);
    const secretAtField = pickStr(o, ["SECRET_AT","secretAt"]);
    const titleField = pickStr(o, ["TITLE","title"]);
    const subTitleField = pickStr(o, ["SUB_TITLE","subTitle"]);
    const summaryTxtField = pickStr(o, ["SUMMARY_TXT","summaryTxt"]);
    const contentHtmlField = pickNum(o, ["CONTENT_HTML","contentHtml"]);
    const tagsField = pickStr(o, ["TAGS","tags"]);
    const thumbUrlField = pickStr(o, ["THUMB_URL","thumbUrl"]);
    const attachJsonField = pickNum(o, ["ATTACH_JSON","attachJson"]);
    const publishStartDtField = pickStr(o, ["PUBLISH_START_DT","publishStartDt"]);
    const publishEndDtField = pickStr(o, ["PUBLISH_END_DT","publishEndDt"]);
    const sortOrdrField = pickNum(o, ["SORT_ORDR","sortOrdr"]);
    const viewCntField = pickNum(o, ["VIEW_CNT","viewCnt"]);
    const likeCntField = pickNum(o, ["LIKE_CNT","likeCnt"]);
    const commentCntField = pickNum(o, ["COMMENT_CNT","commentCnt"]);
    const placeNmField = pickStr(o, ["PLACE_NM","placeNm"]);
    const placeAddrField = pickStr(o, ["PLACE_ADDR","placeAddr"]);
    const latField = pickStr(o, ["LAT","lat"]);
    const lngField = pickStr(o, ["LNG","lng"]);
    const useAtField = pickStr(o, ["USE_AT","useAt"]);
    const delAtField = pickStr(o, ["DEL_AT","delAt"]);
    const delDtField = pickStr(o, ["DEL_DT","delDt"]);
    const delByField = pickStr(o, ["DEL_BY","delBy"]);
    const createdDtField = pickStr(o, ["CREATED_DT","createdDt"]);
    const createdByField = pickStr(o, ["CREATED_BY","createdBy"]);
    const updatedDtField = pickStr(o, ["UPDATED_DT","updatedDt"]);
    const updatedByField = pickStr(o, ["UPDATED_BY","updatedBy"]);

    return {
        id: idField ?? null,
        grpCd: grpCdField ?? null,
        boardCd: boardCdField ?? null,
        categoryCd: categoryCdField ?? null,
        statusCd: statusCdField ?? null,
        noticeAt: noticeAtField ?? null,
        pinAt: pinAtField ?? null,
        secretAt: secretAtField ?? null,
        title: titleField ?? null,
        subTitle: subTitleField ?? null,
        summaryTxt: summaryTxtField ?? null,
        contentHtml: contentHtmlField ?? null,
        tags: tagsField ?? null,
        thumbUrl: thumbUrlField ?? null,
        attachJson: attachJsonField ?? null,
        publishStartDt: publishStartDtField ?? null,
        publishEndDt: publishEndDtField ?? null,
        sortOrdr: sortOrdrField ?? null,
        viewCnt: viewCntField ?? null,
        likeCnt: likeCntField ?? null,
        commentCnt: commentCntField ?? null,
        placeNm: placeNmField ?? null,
        placeAddr: placeAddrField ?? null,
        lat: latField ?? null,
        lng: lngField ?? null,
        useAt: useAtField ?? null,
        delAt: delAtField ?? null,
        delDt: delDtField ?? null,
        delBy: delByField ?? null,
        createdDt: createdDtField ?? null,
        createdBy: createdByField ?? null,
        updatedDt: updatedDtField ?? null,
        updatedBy: updatedByField ?? null,
    };
}

/** 프런트 → 서버 (업서트/전송용) */
export function adaptOutTestt(input: TesttEntry): Record<string, unknown> {
    return {
        TESTT_IDX: input.id ?? null,
        GRP_CD: input.grpCd ?? null,
        BOARD_CD: input.boardCd ?? null,
        CATEGORY_CD: input.categoryCd ?? null,
        STATUS_CD: input.statusCd ?? null,
        NOTICE_AT: input.noticeAt ?? null,
        PIN_AT: input.pinAt ?? null,
        SECRET_AT: input.secretAt ?? null,
        TITLE: input.title ?? null,
        SUB_TITLE: input.subTitle ?? null,
        SUMMARY_TXT: input.summaryTxt ?? null,
        CONTENT_HTML: input.contentHtml ?? null,
        TAGS: input.tags ?? null,
        THUMB_URL: input.thumbUrl ?? null,
        ATTACH_JSON: input.attachJson ?? null,
        PUBLISH_START_DT: input.publishStartDt ?? null,
        PUBLISH_END_DT: input.publishEndDt ?? null,
        SORT_ORDR: input.sortOrdr ?? null,
        VIEW_CNT: input.viewCnt ?? null,
        LIKE_CNT: input.likeCnt ?? null,
        COMMENT_CNT: input.commentCnt ?? null,
        PLACE_NM: input.placeNm ?? null,
        PLACE_ADDR: input.placeAddr ?? null,
        LAT: input.lat ?? null,
        LNG: input.lng ?? null,
        USE_AT: input.useAt ?? null,
        DEL_AT: input.delAt ?? null,
        DEL_DT: input.delDt ?? null,
        DEL_BY: input.delBy ?? null,
        CREATED_DT: input.createdDt ?? null,
        CREATED_BY: input.createdBy ?? null,
        UPDATED_DT: input.updatedDt ?? null,
        UPDATED_BY: input.updatedBy ?? null,
    };
}
