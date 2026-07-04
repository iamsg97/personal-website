import { profile } from "@/content/profile";
import { Cursor } from "@/components/Cursor";
import styles from "./Hero.module.css";

export function Hero() {
  return (
    <section className={styles.hero} aria-label="Introduction">
      <div className="wrap">
        <div className={styles.window}>
          <div className={styles.titlebar}>
            <span className={styles.dots} aria-hidden="true">
              <i />
              <i />
              <i />
            </span>
            <span className={styles.title}>
              {profile.handle}@{profile.host}: ~
            </span>
          </div>

          <div className={styles.body}>
            <p className={styles.cmd}>
              <span className={styles.dollar}>$</span> whoami
            </p>
            <h1 className={styles.name}>{profile.name}</h1>
            <p className={styles.role}>{profile.role}</p>
            <p className={styles.status}>{profile.status}</p>

            <p className={styles.cmd}>
              <span className={styles.dollar}>$</span> cat summary.txt
            </p>
            <p className={styles.summary}>{profile.tagline}</p>

            <p className={styles.cmd}>
              <span className={styles.dollar}>$</span> cat location
            </p>
            <p className={styles.location}>{profile.location}</p>

            <p className={styles.cmd}>
              <span className={styles.dollar}>$</span> ls links/
            </p>
            <div className={styles.links}>
              {profile.socials.map((s) => (
                <a key={s.label} href={s.href} target="_blank" rel="noreferrer noopener">
                  [{s.label}]
                </a>
              ))}
              <a href={`mailto:${profile.email}`}>[email]</a>
              <a href={profile.resumeUrl} target="_blank" rel="noreferrer noopener">
                [résumé&nbsp;↓]
              </a>
            </div>

            <p className={styles.cmd}>
              <span className={styles.dollar}>$</span> <Cursor />
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}
