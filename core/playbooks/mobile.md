# Playbook: Mobile Application

## Phase 1: Setup & Extraction

### Android Setup
```
Objective: Set up Android testing environment
Steps:
1. APK acquisition: Google Play, APKPure, APKMirror, adb pull
2. Decompile: jadx, apktool, dex2jar
3. Set up proxy: mitmproxy/Burp + Frida for cert pinning bypass
4. Emulator or rooted device ready
5. Frida/Objection installed and working
```

### iOS Setup
```
Objective: Set up iOS testing environment
Steps:
1. IPA acquisition: Jailbroken device, App Store download
2. Decrypt: frida-ios-dump, Clutch2
3. Decompile: Hopper, IDA, class-dump
4. Set up proxy with SSL kill switch / Frida
5. Jailbroken device or Corellium ready
```

## Phase 2: Static Analysis

### Binary Analysis Worker
```
Objective: Analyze [APK/IPA] for security issues
Steps:
1. Check for hardcoded secrets (API keys, passwords, tokens)
2. Find all URLs/endpoints in binary
3. Check certificate pinning implementation
4. Review encryption usage (weak algorithms, hardcoded keys)
5. Check for debug/logging code left in release
6. Review AndroidManifest.xml / Info.plist for dangerous permissions
7. Check exported components (Android: activities, services, receivers, providers)
8. Check URL schemes and deeplinks
Output: Static findings with file paths and code snippets
```

### Data Storage Worker
```
Objective: Check insecure data storage
Steps:
1. Check SharedPreferences / NSUserDefaults for sensitive data
2. Check SQLite databases for unencrypted PII
3. Check file storage permissions
4. Check backup allowance (android:allowBackup)
5. Check clipboard usage with sensitive data
6. Check KeyStore / Keychain usage
Output: Data storage issues with evidence
```

## Phase 3: Dynamic Analysis

### Network Traffic Worker
```
Objective: Intercept and analyze API traffic
Steps:
1. Set up proxy (bypass cert pinning if needed)
2. Exercise all app features — map complete API surface
3. Check for:
   - Unencrypted traffic (HTTP)
   - Missing auth on sensitive endpoints
   - Excessive data in responses
   - Hardcoded tokens in requests
   - API versioning differences from web
4. Save all requests/responses for analysis
Output: Complete API map + network security findings
```

### Runtime Manipulation Worker
```
Objective: Test runtime security of [app]
Steps:
1. Frida hooks on sensitive functions:
   - Authentication checks
   - Encryption/decryption
   - Root/jailbreak detection
   - SSL pinning
2. Bypass local authentication (biometric, PIN)
3. Modify function return values
4. Hook crypto functions to extract keys
5. Test debug detection bypass
Output: Runtime bypass findings with Frida scripts
```

## Phase 4: Platform-Specific Tests

### Android-Specific
| Test | Check | Impact |
|------|-------|--------|
| Exported components | adb shell dumpsys + intent manipulation | HIGH |
| Content providers | query accessible providers for data leak | HIGH |
| Deeplink abuse | crafted intents/URLs for unauthorized actions | MEDIUM-HIGH |
| WebView attacks | JavaScript bridges, file:// protocol | HIGH |
| Broadcast receivers | Send crafted broadcasts | MEDIUM |
| Task hijacking | Activity launch mode abuse | MEDIUM |
| Tapjacking | Overlay attacks on sensitive screens | MEDIUM |

### iOS-Specific
| Test | Check | Impact |
|------|-------|--------|
| URL schemes | Custom scheme hijacking | MEDIUM-HIGH |
| Universal links | AASA file misconfiguration | MEDIUM |
| ATS exceptions | Insecure transport allowed | MEDIUM |
| Pasteboard leaks | Sensitive data in clipboard | LOW-MEDIUM |
| Snapshot leaks | Sensitive data in app snapshots | LOW |
| Extension abuse | Share extension data leakage | MEDIUM |

## Phase 5: Server-Side (via Mobile)

Mobile apps often have weaker server-side controls than web:
- Missing rate limiting on mobile-specific APIs
- Less strict input validation
- Hidden admin endpoints in old API versions
- Different auth tokens with broader scope
- Push notification token leakage

→ Apply `api.md` playbook on the discovered mobile API surface.

## Tools Reference

| Category | Tools |
|----------|-------|
| Decompile (Android) | jadx, apktool, dex2jar |
| Decompile (iOS) | Hopper, IDA, class-dump |
| Runtime (Android) | Frida, Objection, MagiskHide |
| Runtime (iOS) | Frida, Objection, SSL Kill Switch |
| Proxy | mitmproxy, Burp Suite, Charles |
| Automation | Drozer (Android), idb (iOS) |
| Emulation | Genymotion, Corellium |
