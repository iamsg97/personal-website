"use client";

import { useEffect, useState } from "react";
import { sections } from "@/lib/sections";
import { profile } from "@/content/profile";
import { ThemeToggle } from "./ThemeToggle";
import styles from "./Nav.module.css";

export function Nav() {
  const [active, setActive] = useState<string>("");

  // Scroll-spy: highlight the section currently near the middle of the viewport.
  useEffect(() => {
    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) setActive(entry.target.id);
        }
      },
      { rootMargin: "-45% 0px -50% 0px", threshold: 0 },
    );

    for (const s of sections) {
      const el = document.getElementById(s.id);
      if (el) observer.observe(el);
    }
    return () => observer.disconnect();
  }, []);

  // Keyboard nav: digits 1-6 jump to a section, j/k cycle, g/G top/bottom.
  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if (e.metaKey || e.ctrlKey || e.altKey) return;
      const el = document.activeElement;
      if (el && ["INPUT", "TEXTAREA", "SELECT"].includes(el.tagName)) return;

      const jump = (id: string) => document.getElementById(id)?.scrollIntoView();

      const digit = Number(e.key);
      if (digit >= 1 && digit <= sections.length) {
        jump(sections[digit - 1].id);
        return;
      }

      const idx = sections.findIndex((s) => s.id === active);
      if (e.key === "j")
        jump(sections[Math.min(idx + 1, sections.length - 1)]?.id ?? sections[0].id);
      else if (e.key === "k") jump(sections[Math.max(idx - 1, 0)]?.id ?? sections[0].id);
      else if (e.key === "g") window.scrollTo({ top: 0 });
      else if (e.key === "G") jump(sections[sections.length - 1].id);
    }

    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [active]);

  return (
    <header className={styles.header}>
      <div className={`wrap ${styles.inner}`}>
        <button
          type="button"
          className={styles.home}
          onClick={() => window.scrollTo({ top: 0 })}
          aria-label="Scroll to top"
        >
          <span className={styles.user}>{profile.handle}</span>
          <span className={styles.at}>@{profile.host}</span>
          <span className={styles.dollar}>:~$</span>
        </button>

        <nav aria-label="Sections" className={styles.links}>
          {sections.map((s) => (
            <a
              key={s.id}
              href={`#${s.id}`}
              className={active === s.id ? `${styles.link} ${styles.linkActive}` : styles.link}
              aria-current={active === s.id ? "true" : undefined}
            >
              ./{s.label}
            </a>
          ))}
        </nav>

        <ThemeToggle />
      </div>
    </header>
  );
}
