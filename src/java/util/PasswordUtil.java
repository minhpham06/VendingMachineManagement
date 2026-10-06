package util;

import java.security.SecureRandom;
import java.security.spec.KeySpec;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

/**
 * Băm mật khẩu bằng PBKDF2WithHmacSHA256 (20,000 vòng băm + salt 16-byte).
 */
public class PasswordUtil {

    private static final int ITERATIONS = 20000;
    private static final int KEY_BITS = 256;
    private static final SecureRandom RANDOM = new SecureRandom();

    public static String hash(String plain) {
        if (plain == null) plain = "";
        byte[] salt = new byte[16];
        RANDOM.nextBytes(salt);
        byte[] key = pbkdf2(plain.toCharArray(), salt, ITERATIONS);
        return ITERATIONS + ":" + toHex(salt) + ":" + toHex(key);
    }

    public static boolean verify(String plain, String stored) {
        if (plain == null || stored == null) return false;
        String[] parts = stored.split(":");
        if (parts.length != 3) return false;
        try {
            int iterations = Integer.parseInt(parts[0]);
            byte[] salt = fromHex(parts[1]);
            byte[] expected = fromHex(parts[2]);
            byte[] actual = pbkdf2(plain.toCharArray(), salt, iterations);
            if (actual.length != expected.length) return false;
            int diff = 0;
            for (int i = 0; i < actual.length; i++) diff |= actual[i] ^ expected[i];
            return diff == 0;
        } catch (Exception ex) {
            return false;
        }
    }

    private static byte[] pbkdf2(char[] plain, byte[] salt, int iterations) {
        try {
            KeySpec spec = new PBEKeySpec(plain, salt, iterations, KEY_BITS);
            SecretKeyFactory f = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
            return f.generateSecret(spec).getEncoded();
        } catch (Exception ex) {
            throw new RuntimeException("PBKDF2 algorithm not supported in this JVM", ex);
        }
    }

    private static String toHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) {
            sb.append(String.format("%02x", b & 0xff));
        }
        return sb.toString();
    }

    private static byte[] fromHex(String hex) {
        int len = hex.length();
        byte[] data = new byte[len / 2];
        for (int i = 0; i < len; i += 2) {
            data[i / 2] = (byte) ((Character.digit(hex.charAt(i), 16) << 4)
                                 + Character.digit(hex.charAt(i + 1), 16));
        }
        return data;
    }
}
