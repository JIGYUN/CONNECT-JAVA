package www.com.spring.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.AbstractWebSocketMessageBrokerConfigurer;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;

@Configuration
@EnableWebSocketMessageBroker
public class WebSocketConfig extends AbstractWebSocketMessageBrokerConfigurer {

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // 클라이언트에서 연결할 엔드포인트: /ws-stomp
        registry.addEndpoint("/ws-stomp")
                .setAllowedOrigins("*")
                .withSockJS();   // JSP + 레거시 브라우저 대비
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        // 서버 → 클라이언트 브로드캐스트 prefix
        registry.enableSimpleBroker("/topic");
        // 클라이언트 → 서버 발행 prefix
        registry.setApplicationDestinationPrefixes("/app");
    }
}
