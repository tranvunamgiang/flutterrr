package com.tns.newscrawler.config;

import com.tns.newscrawler.security.JwtAuthenticationFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    private final AuthenticationProvider authenticationProvider; // Inject từ AppConfig

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // 1. Tắt CSRF (Bắt buộc để Postman và Next.js gọi được API POST/PUT/DELETE)
                .csrf(AbstractHttpConfigurer::disable)

                // 2. Cấu hình CORS
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))

                // 3. Chế độ không lưu Session (Stateless) - Quan trọng cho JWT
                .sessionManagement(sess -> sess.sessionCreationPolicy(SessionCreationPolicy.STATELESS))

                // 4. Xác thực Provider
                .authenticationProvider(authenticationProvider)

                // 5. Phân quyền
                .authorizeHttpRequests(auth -> auth
                        // Swagger & Docs
                        .requestMatchers(
                                "/v3/api-docs/**",
                                "/swagger-ui/**",
                                "/swagger-ui.html",
                                "/swagger-resources/**",
                                "/webjars/**"
                        ).permitAll()

                        // Public API (Trang chủ, Bài viết, Danh mục)
                        .requestMatchers(
                                "/",
                                "/article/**",
                                "/category/**",
                                "/api/public/**",
                                "/api/auth/**" // Login, Logout
                        ).permitAll()

                        // Admin API
                        // ⚠️ LƯU Ý: Đang để .permitAll() để em test Postman cho dễ.
                        // Khi nào xong xuôi nhớ đổi lại thành: .hasRole("ADMIN")
                        .requestMatchers("/api/admin/**").permitAll()

                        // Các request còn lại bắt buộc login
                        .anyRequest().authenticated()
                )

                // 6. Thêm Filter JWT
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    // Cấu hình CORS chuẩn cho Next.js
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();

        // Cho phép các nguồn Frontend
        config.setAllowedOriginPatterns(List.of(
                "http://localhost:3000",
                "http://localhost:5173",
                "https://fe-assignment-group.vercel.app",
                "https://*.vercel.app"
        ));

        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"));
        config.setAllowedHeaders(List.of("*")); // Cho phép mọi Header (Authorization, Content-Type...)
        config.setExposedHeaders(List.of("Set-Cookie", "Authorization"));
        config.setAllowCredentials(true); // Cho phép gửi Cookie/Token

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }
}