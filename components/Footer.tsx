import { profile } from "@/content/profile";
import styles from "./Footer.module.css";

export function Footer() {
  const year = new Date().getFullYear();
  return (
    <footer className={styles.footer}>
      <div className="wrap">
        <div className={styles.grid}>
          <p className={styles.line}>
            <span className={styles.comment}># {profile.name}</span> — built with Next.js,
            hand-written CSS, and Neovim.
          </p>
          <ul className={styles.socials}>
            {profile.socials.map((s) => (
              <li key={s.label}>
                <a href={s.href} target="_blank" rel="me noreferrer noopener">
                  {s.label}
                </a>
              </li>
            ))}
          </ul>
        </div>
        <p className={styles.meta}>
          <span className={styles.comment}>
            $ echo &quot;© {year} — no rights reserved, take what&apos;s useful&quot;
          </span>
        </p>
      </div>
    </footer>
  );
}
