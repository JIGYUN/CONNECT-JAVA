// filepath: src/main/java/www/com/firebase/PushSenderMap.java
package www.com.firebase;

import java.util.*;
import com.google.firebase.messaging.*;
import org.springframework.stereotype.Component;

/**
 * DTO 없이 Map으로만 주고받는 FCM 전송 유틸.
 *
 * 입력 payload 키 약속:
 *  - title           : String
 *  - body            : String
 *  - imageUrl        : String(선택)
 *  - clickAction     : String(선택)
 *  - ttlSec          : Integer(선택, 초 단위)
 *  - highPriority    : Boolean(기본 true)
 *  - data            : Map<String,String>(선택)
 */
@Component
public class PushSenderMap {

    /* ───────── 단건 토큰 ───────── */
    public Map<String,Object> sendToToken(String token, Map<String,Object> payload) throws Exception {
        if (token == null || token.trim().isEmpty())
            return result(0,0, Collections.emptyList(), "EMPTY_TOKEN");

        Message message = buildMessageForToken(token, payload);
        String id = FirebaseAdminHolder.getMessaging().send(message);
        return result(1,0, Collections.emptyList(), null, id);
    }

    /* ───────── 다중 토큰(자동 500개 청크) ───────── */
    public Map<String,Object> sendToTokens(List<String> tokens, Map<String,Object> payload) throws Exception {
        if (tokens == null || tokens.isEmpty())
            return result(0,0, Collections.emptyList(), "NO_TARGET");

        List<String> filtered = new ArrayList<>();
        for (String t : tokens) if (t != null && !t.trim().isEmpty()) filtered.add(t.trim());
        if (filtered.isEmpty()) return result(0,0, Collections.emptyList(), "NO_TARGET");

        int ok=0, ng=0; String lastErr=null;
        List<String> bad = new ArrayList<>();

        int i=0, n=filtered.size();
        while (i<n) {
            int end = Math.min(i+500, n);
            List<String> slice = filtered.subList(i, end);

            MulticastMessage msg = buildMulticastMessage(slice, payload);
            BatchResponse br = FirebaseAdminHolder.getMessaging().sendEachForMulticast(msg);

            ok += br.getSuccessCount();
            ng += br.getFailureCount();

            List<SendResponse> resps = br.getResponses();
            for (int k=0; k<resps.size(); k++) {
                SendResponse r = resps.get(k);
                if (!r.isSuccessful()) {
                    bad.add(slice.get(k));
                    lastErr = r.getException()!=null ? r.getException().getMessage() : "unknown";
                }
            }
            i = end;
        }
        return result(ok, ng, bad, lastErr);
    }

    /* ───────── 토픽 ───────── */
    public Map<String,Object> sendToTopic(String topic, Map<String,Object> payload) throws Exception {
        if (topic == null || topic.trim().isEmpty())
            return result(0,0, Collections.emptyList(), "EMPTY_TOPIC");

        Message message = buildMessageForTopic(topic, payload);
        String id = FirebaseAdminHolder.getMessaging().send(message);
        return result(1,0, Collections.emptyList(), null, id);
    }

    /* ───────── builders ───────── */
    private Message buildMessageForToken(String token, Map<String,Object> p) {
        return Message.builder()
            .setToken(token)
            .setNotification(buildNotification(p))
            .putAllData(getData(p))
            .setAndroidConfig(buildAndroid(p))
            .setApnsConfig(buildApns(p))
            .setFcmOptions(FcmOptions.withAnalyticsLabel("connect_push"))
            .build();
    }

    private MulticastMessage buildMulticastMessage(List<String> tokens, Map<String,Object> p) {
        return MulticastMessage.builder()
            .addAllTokens(tokens)
            .setNotification(buildNotification(p))
            .putAllData(getData(p))
            .setAndroidConfig(buildAndroid(p))
            .setApnsConfig(buildApns(p))
            .setFcmOptions(FcmOptions.withAnalyticsLabel("connect_push"))
            .build();
    }

    private Message buildMessageForTopic(String topic, Map<String,Object> p) {
        return Message.builder()
            .setTopic(topic)
            .setNotification(buildNotification(p))
            .putAllData(getData(p))
            .setAndroidConfig(buildAndroid(p))
            .setApnsConfig(buildApns(p))
            .setFcmOptions(FcmOptions.withAnalyticsLabel("connect_push"))
            .build();
    }

    private Notification buildNotification(Map<String,Object> p) {
        Notification.Builder b = Notification.builder();
        String title = str(p,"title");
        String body  = str(p,"body");
        String img   = str(p,"imageUrl");
        if (title != null) b.setTitle(title);
        if (body  != null) b.setBody(body);
        if (img   != null) b.setImage(img);
        return b.build();
    }

    private AndroidConfig buildAndroid(Map<String,Object> p) {
        AndroidConfig.Builder ab = AndroidConfig.builder();
        boolean high = bool(p, "highPriority", true);
        ab.setPriority(high ? AndroidConfig.Priority.HIGH : AndroidConfig.Priority.NORMAL);

        Integer ttl = intOrNull(p, "ttlSec");
        if (ttl != null && ttl > 0) {
            // Firebase Admin SDK v9: 밀리초 long
            ab.setTtl(ttl.longValue() * 1000L);
        }

        AndroidNotification.Builder an = AndroidNotification.builder();
        String click = str(p,"clickAction");
        String img   = str(p,"imageUrl");
        if (click != null) an.setClickAction(click);
        if (img   != null) an.setImage(img);
        ab.setNotification(an.build());
        return ab.build();
    }

    private ApnsConfig buildApns(Map<String,Object> p) {
        return ApnsConfig.builder().setAps(Aps.builder().build()).build();
    }

    /* ───────── results ───────── */
    private Map<String,Object> result(int ok, int ng, List<String> bad, String err) {
        return result(ok, ng, bad, err, null);
    }
    private Map<String,Object> result(int ok, int ng, List<String> bad, String err, String msgId) {
        Map<String,Object> m = new HashMap<>();
        m.put("successCnt", ok);
        m.put("failCnt", ng);
        m.put("failedTokens", bad==null? Collections.emptyList() : bad);
        m.put("lastErrorSummary", err);
        if (msgId != null) m.put("messageId", msgId);
        return m;
    }

    /* ───────── small utils ───────── */
    @SuppressWarnings("unchecked")
    private Map<String,String> getData(Map<String,Object> p) {
        Object v = p.get("data");
        if (v instanceof Map) {
            Map<?,?> raw = (Map<?,?>) v;
            Map<String,String> r = new HashMap<>();
            for (Map.Entry<?,?> e : raw.entrySet()) {
                Object k = e.getKey(), val = e.getValue();
                if (k != null && val != null) r.put(String.valueOf(k), String.valueOf(val));
            }
            return r;
        }
        return Collections.emptyMap();
    }
    private static String str(Map<String,Object> p, String k) {
        Object v = p.get(k);
        return v == null ? null : String.valueOf(v);
    }
    private static boolean bool(Map<String,Object> p, String k, boolean dft) {
        Object v = p.get(k);
        if (v == null) return dft;
        if (v instanceof Boolean) return (Boolean)v;
        String s = String.valueOf(v);
        return "true".equalsIgnoreCase(s) || "1".equals(s) || "Y".equalsIgnoreCase(s);
    }
    private static Integer intOrNull(Map<String,Object> p, String k) {
        Object v = p.get(k);
        if (v == null) return null;
        if (v instanceof Number) return ((Number)v).intValue();
        try { return Integer.parseInt(String.valueOf(v).trim()); } catch (Exception ignore) { return null; }
    }
}