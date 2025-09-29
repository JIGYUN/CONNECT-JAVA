package www.com.user.service;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;

import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

/**
 * 인증된 사용자 VO (TB_USER 매핑)
 * USER_ID -> userId, EMAIL -> email, PASSWORD_HASH -> passwordHash,
 * USER_NM -> userNm, nickNm -> nickNm, PROFILE_IMG_URL -> profileImgUrl,
 * TELNO -> telno, AUTH_TYPE -> authType
 */
public class UserVO implements UserDetails, Serializable {

    private static final long serialVersionUID = 3258562207857181402L;

    // ====== TB_USER Columns ======
    private String userId;         // USER_ID (BIGINT)
    private String email;          // EMAIL
    private String passwordHash;   // PASSWORD_HASH
    private String userNm;         // USER_NM (실명/이름)
    private String nickNm;       // nickNm (표시용 별명)
    private String profileImgUrl;  // PROFILE_IMG_URL (아바타)
    private String telno;          // TELNO
    private String authType;       // AUTH_TYPE: 'U' | 'A' | 'G'...

    // Spring Security
    private Collection<GrantedAuthority> authorities;

    public UserVO() {}

    public UserVO(String userId, String email, String passwordHash,
                  String userNm, String nickNm, String profileImgUrl,
                  String telno, String authType) {
        this.userId = userId;
        this.email = email;
        this.passwordHash = passwordHash;
        this.userNm = userNm;
        this.nickNm = nickNm;
        this.profileImgUrl = profileImgUrl;
        this.telno = telno;
        this.authType = authType;
    }

    // ====== Convenience ======
    public boolean isAdmin() { return "A".equalsIgnoreCase(this.authType); }

    public void setAuthorities(Collection<GrantedAuthority> authorities) {
        this.authorities = (authorities == null)
                ? null
                : Collections.unmodifiableCollection(authorities);
    }

    // ====== UserDetails ======
    @Override public Collection<? extends GrantedAuthority> getAuthorities() {
        if (this.authorities == null) {
            ArrayList<GrantedAuthority> list = new ArrayList<>();
            list.add(new SimpleGrantedAuthority("USER")); // prefix 정책에 따라 ROLE_USER 로 바꿀 수 있음
            if (isAdmin()) list.add(new SimpleGrantedAuthority("ADMIN"));
            return Collections.unmodifiableCollection(list);
        }
        return this.authorities;
    }
    @Override public String getPassword() { return this.passwordHash; }
    @Override public String getUsername() { return this.email; }
    @Override public boolean isAccountNonExpired()     { return true; }
    @Override public boolean isAccountNonLocked()      { return true; }
    @Override public boolean isCredentialsNonExpired() { return true; }
    @Override public boolean isEnabled()               { return true; }

    // ====== Getters/Setters ======
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getUserNm() { return userNm; }
    public void setUserNm(String userNm) { this.userNm = userNm; }

    public String getNickNm() { return nickNm; }
    public void setNickNm(String nickNm) { this.nickNm = nickNm; }

    public String getProfileImgUrl() { return profileImgUrl; }
    public void setProfileImgUrl(String profileImgUrl) { this.profileImgUrl = profileImgUrl; }

    public String getTelno() { return telno; }
    public void setTelno(String telno) { this.telno = telno; }

    public String getAuthType() { return authType; }
    public void setAuthType(String authType) { this.authType = authType; }
}