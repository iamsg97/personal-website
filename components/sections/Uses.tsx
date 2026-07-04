import { Section } from "@/components/Section";
import { uses, usesIntro, usesRepo } from "@/content/uses";
import styles from "./Uses.module.css";

export function Uses() {
  return (
    <Section id="uses" command="cat ~/.dotfiles">
      <p className={styles.intro}>{usesIntro}</p>

      <dl className={styles.list}>
        {uses.map((group) => (
          <div key={group.label} className={styles.row}>
            <dt className={styles.key}>{group.label}</dt>
            <dd className={styles.val}>{group.items.join("  ·  ")}</dd>
          </div>
        ))}
      </dl>

      <p className={styles.repo}>
        <span className={styles.dollar}>$</span> git clone{" "}
        <a href={usesRepo} target="_blank" rel="noreferrer noopener">
          {usesRepo.replace("https://", "")}
        </a>
      </p>
    </Section>
  );
}
