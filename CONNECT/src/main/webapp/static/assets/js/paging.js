(function (global) {
    'use strict';

    function clamp(n, min, max) { return Math.max(min, Math.min(max, n)); }
    function assign(dst, src) { for (var k in src) if (Object.prototype.hasOwnProperty.call(src, k)) dst[k] = src[k]; return dst; }

    // --- storage helpers ---
    function readSS(key) {
        try { var v = sessionStorage.getItem(key); return v ? JSON.parse(v) : null; } catch (e) { return null; }
    }
    function writeSS(key, obj) {
        try { sessionStorage.setItem(key, JSON.stringify(obj)); } catch (e) {}
    }

    // --- hash helpers (#p=2&s=20) ---
    function parseHash() {
        var h = (location.hash || '').replace(/^#/, '');
        var out = {};
        if (!h) return out;
        h.split('&').forEach(function (kv) {
            var a = kv.split('=');
            if (a.length === 2) out[a[0]] = a[1];
        });
        var p = parseInt(out.p, 10); var s = parseInt(out.s, 10);
        return {
            page: (isFinite(p) && p > 0) ? p : undefined,
            size: (isFinite(s) && s > 0) ? s : undefined
        };
    }
    function writeHash(meta) {
        var parts = [];
        if (meta.page) parts.push('p=' + meta.page);
        if (meta.size) parts.push('s=' + meta.size);
        var str = parts.join('&');
        if (str) location.hash = str; else history.replaceState(null, '', location.pathname + location.search);
    }

    function Paging(container, onChange, opts) {
        if (!container) throw new Error('Paging: container required');
        if (typeof onChange !== 'function') throw new Error('Paging: onChange(page, size) required');

        this.root = (typeof container === 'string') ? document.querySelector(container) : container;
        this.onChange = onChange;
        this.opts = assign({
            size: 20,
            maxButtons: 7,
            showFirstLast: true,
            showSummary: true,
            autoLoad: false,
            key: 'default'        // 페이지별로 의미 있는 키 전달 권장 (예: 'boardPost')
        }, opts || {});

        this.state = {
            page: 1,
            size: this.opts.size,
            total: 0,
            totalPages: 0,
            offset: 0,
            limit: this.opts.size
        };

        // 저장 키 (검색쿼리는 포함하지 않음)
        this._storeKey = location.pathname + '::' + this.opts.key;

        // 최초에는 저장 금지(초기 기본값 1이 세션을 덮어쓰지 않도록)
        this._persistEnabled = false;

        // 기본 컨테이너 UI
        this.root.innerHTML = [
            '<div class="pg-wrap" style="display:flex;gap:8px;align-items:center;flex-wrap:wrap;">',
            '  <div class="pg-summary" style="color:#6b7280;font-size:.92rem;"></div>',
            '  <div class="pg-size" style="margin-left:auto;display:flex;gap:6px;align-items:center;">',
            '    <label style="margin:0;color:#6b7280;font-size:.92rem;">Rows</label>',
            '    <select class="pg-size-select" style="border-radius:10px;padding:4px 8px;">',
            '      <option value="10">10</option>',
            '      <option value="20" selected>20</option>',
            '      <option value="30">30</option>',
            '      <option value="50">50</option>',
            '    </select>',
            '  </div>',
            '</div>',
            '<nav class="pg-nav" aria-label="pagination" style="width:100%;">',
            '  <ul class="pg-ul pagination" style="margin:8px 0 0;"></ul>',
            '</nav>'
        ].join('');

        this.$summary = this.root.querySelector('.pg-summary');
        this.$ul = this.root.querySelector('.pg-ul');
        this.$sel = this.root.querySelector('.pg-size-select');

        var self = this;
        this.$sel.addEventListener('change', function () {
            var v = parseInt(self.$sel.value, 10) || 20;
            self.setSize(v);                  // setSize → go(1, true)
        });

        // 초기 복원(읽기만) — 여기서는 절대 session/hash에 "쓰기" 금지
        var saved = readSS(this._storeKey) || {};
        console.log(saved);  
        var hash = parseHash();
        var initSize = (hash.size || saved.size || this.state.size);
        var initPage = (hash.page || saved.page || 1);

        if (isFinite(initSize) && initSize > 0) {
            this.state.size = initSize;
            this.state.limit = initSize;
            this.$sel.value = String(initSize);
        }
        console.log(isFinite(initPage));  
        console.log(initPage); 
        console.log(this.state.page);  
        if (isFinite(initPage) && initPage > 0) {
            this.state.page = initPage;     // 참고값으로만 보관(실제 조회는 외부에서 go 호출)
            console.log(this.state.page);    
            this.state.offset = (initPage - 1) * this.state.size;
        }
        
        console.log(this.state); 

        this.render();

        // autoLoad 옵션이면, 첫 호출도 저장 없이 강제 호출
        if (this.opts.autoLoad) {
            this.go(this.state.page || 1, true /*force*/, true /*noPersist*/); 
        }
    }

    Paging.prototype.getState = function () {
        return assign({}, this.state);
    };

    Paging.prototype._persist = function () {
        if (!this._persistEnabled) return;
        var s = this.state;
        writeSS(this._storeKey, { page: s.page, size: s.size, ts: Date.now() });
        writeHash({ page: s.page, size: s.size });
    };

    Paging.prototype.setSize = function (size) {
        size = parseInt(size, 10) || 20;
        if (size === this.state.size) return;
        this.state.size = size;
        this.state.limit = size;
        this.$sel.value = String(size);
        // 사이즈 변경은 보통 1페이지부터 – 첫 호출에서는 noPersist로
        this.go(1, true, !this._persistEnabled);
    };

    /**
     * go(page, force=false, noPersist=false)
     *  - force: 같은 페이지여도 onChange 호출
     *  - noPersist: 이번 호출에 한해 저장 금지(초기 1회용)
     */ 
 // paging.js - go() 교체본 (들여쓰기 4칸)
    Paging.prototype.go = function (page, force, noPersist) {
        var s = this.state;

        // 요청값 정규화 (하한만 보장)
        var requested = parseInt(page, 10) || 1;
        if (requested < 1) requested = 1;

        // totalPages를 아직 모를 때(=0)는 상한 클램프를 하지 않는다
        var nextPage;
        if (s.totalPages && s.totalPages > 0) {
            // 이미 메타가 있는 상태 → 정상 상한 클램프
            var maxPage = Math.max(1, s.totalPages);
            nextPage = Math.min(requested, maxPage);
        } else {
            // 초기 호출(메타 없음) → 상한 클램프 금지
            nextPage = requested;
        }

        var samePage = (nextPage === s.page);

        // 상태 반영
        s.page = nextPage;
        s.offset = (nextPage - 1) * s.size;

        // 같은 페이지이고 강제 아님 + totalPages를 이미 알고 있으면 스킵
        if (samePage && !force && s.totalPages > 0) {
            return;
        }

        // 서버 조회 트리거 (update()에서 meta 반영 후 persist)
        this.onChange(nextPage, s.size);

        // 초기 호출은 noPersist=true로 오기 때문에 여기서 저장하지 않음
        // 저장은 update()에서만 수행 (기존 정책 유지)
    };   

    /**
     * 서버 메타 반영. 이 시점부터 저장 허용!
     * 기대 메타: { page, size, total, totalPages, offset, limit }
     */
    Paging.prototype.update = function (meta) {
        if (!meta) return;
        var s = this.state;

        s.page = parseInt(meta.page, 10) || s.page || 1;
        s.size = parseInt(meta.size, 10) || s.size || this.opts.size;
        s.total = parseInt(meta.total, 10) || 0;
        s.totalPages = parseInt(meta.totalPages, 10) || Math.ceil(s.total / Math.max(1, s.size));
        s.offset = parseInt(meta.offset, 10) || ((s.page - 1) * s.size);
        s.limit = parseInt(meta.limit, 10) || s.size;

        // select 동기화
        if (this.$sel && this.$sel.value !== String(s.size)) this.$sel.value = String(s.size);

        // 이제부터 저장 허용 (최초 update에서 on)
        this._persistEnabled = true;
        this._persist();

        this.render();
    };

    Paging.prototype.render = function () {
        var s = this.state, o = this.opts;
        var ul = this.$ul;
        ul.innerHTML = '';

        // Summary
        if (o.showSummary) {
            var start = (s.total === 0) ? 0 : (s.offset + 1);
            var end = Math.min(s.offset + s.size, s.total);
            this.$summary.textContent = (s.total > 0) ? (start + '–' + end + ' of ' + s.total) : '0 of 0';
            this.$summary.style.display = '';
        } else {
            this.$summary.style.display = 'none';
        }

        var self = this;
        function li(label, page, disabled, active, title) {
            var li = document.createElement('li');
            li.className = 'page-item' + (disabled ? ' disabled' : '') + (active ? ' active' : '');
            var a = document.createElement('a');
            a.className = 'page-link';
            a.href = 'javascript:void(0)';
            a.innerHTML = label;
            if (title) a.title = title;
            if (!disabled && !active) a.addEventListener('click', function () { self.go(page); });
            li.appendChild(a);
            ul.appendChild(li);
        }

        var totalPages = Math.max(1, s.totalPages || 1);
        var cur = clamp(s.page || 1, 1, totalPages);

        // First/Prev
        if (o.showFirstLast) li('&laquo;', 1, cur === 1, false, 'First');
        li('&lsaquo;', cur - 1, cur === 1, false, 'Prev');

        // number window
        var maxBtns = Math.max(3, o.maxButtons || 7);
        var half = Math.floor(maxBtns / 2);
        var start = Math.max(1, cur - half);
        var end = Math.min(totalPages, start + maxBtns - 1);
        if (end - start + 1 < maxBtns) start = Math.max(1, end - maxBtns + 1);

        for (var p = start; p <= end; p++) li(String(p), p, false, p === cur);

        // Next/Last
        li('&rsaquo;', cur + 1, cur === totalPages, false, 'Next');
        if (o.showFirstLast) li('&raquo;', totalPages, cur === totalPages, false, 'Last');
    };

    function create(container, onChange, opts) {
        return new Paging(container, onChange, opts);
    }

    // 외부에서 쓰는 도우미(충돌 방지용 readonly)
    create.parseHash = parseHash;

    global.Paging = { create: create, parseHash: parseHash };

})(window);   