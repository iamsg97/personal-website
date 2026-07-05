"use client";

import { useEffect, useRef, type ReactNode } from "react";
import styles from "./Reveal.module.css";

interface RevealProps {
  children: ReactNode;
}

/**
 * Reveals server-rendered children on scroll, showing a terminal skeleton in
 * the interim. SEO/no-JS safe: children are always in the DOM and visible by
 * default — the wrapper only *arms* the hidden state once JS runs, and only for
 * content that is below the fold at load, so there is no visible flash.
 *
 * Uses ref + `dataset` toggles rather than React state, so it never trips the
 * react-hooks set-state-in-effect rule (same reason ThemeToggle avoids effects).
 */
export function Reveal({ children }: RevealProps) {
  const ref = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const el = ref.current;
    if (!el) return;

    const reduce = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    const rect = el.getBoundingClientRect();
    const inView = rect.top < window.innerHeight && rect.bottom > 0;

    // Anything already on screen, reduced-motion, or no observer: show at once.
    if (reduce || inView || typeof IntersectionObserver === "undefined") {
      el.dataset.revealed = "1";
      return;
    }

    el.dataset.armed = "1";
    const observer = new IntersectionObserver(
      (entries) => {
        for (const entry of entries) {
          if (entry.isIntersecting) {
            el.dataset.revealed = "1";
            observer.disconnect();
          }
        }
      },
      { rootMargin: "0px 0px -10% 0px" },
    );
    observer.observe(el);
    return () => observer.disconnect();
  }, []);

  return (
    <div ref={ref} className={styles.wrap}>
      <p className={styles.skeleton} aria-hidden="true">
        loading
        <span className="cursor" />
      </p>
      <div className={styles.content}>{children}</div>
    </div>
  );
}
