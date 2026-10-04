package util;

import java.security.SecureRandom;
import java.security.spec.KeySpec;
import javax.crypto.SecretKeyFactory;
import javax.crypto.spec.PBEKeySpec;

/**
 * Password hashing with PBKDF2, which ships inside the JDK. No extra jar is
 * needed, so the project opens and runs on the exam machine untouched.
 *
 * A stored value looks like  iterations:saltHex:hashHex  and already carries its
 * own salt, so two users with the same password get two different rows.
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
            return diff == 0; // constant time compare
        } catch (Exception ex) {
            return false;
        }
    }

    private static byte[] pbkdf2(char[] plain, byte[] salt, int iterations) {
        try {
            KeySpec spec = new PBEKeySpec(plain, salt, iterations, KEY_BITS);
            SecretKeyFactory f = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256");
            return f.generateSecret(spec).getEncoded();
        } catch (Exception e) {
            throw new RuntimeException("Cannot hash the password with PBKDF2WithHmacSHA256", e);
        }
    }

    private static String toHex(byte[] b) {
        StringBuilder sb = new StringBuilder(b.length * 2);
        for (int i = 0; i < b.length; i++) {
            String h = Integer.toHexString(b[i] & 0xff);
            if (h.length() == 1) sb.append('0');
            sb.append(h);
        }
        return sb.toString();
    }

    private static byte[] fromHex(String s) {
        byte[] out = new byte[s.length() / 2];
        for (int i = 0; i < out.length; i++) {
            out[i] = (byte) Integer.parseInt(s.substring(i * 2, i * 2 + 2), 16);
        }
        return out;
    }

    public static void main(String[] args) {
        String pwd = args.length > 0 ? args[0] : "123456";
        String h = hash(pwd);
        System.out.println("Password: " + pwd);
        System.out.println("Hash: " + h);
        System.out.println("Verify: " + verify(pwd, h));
    }
}
