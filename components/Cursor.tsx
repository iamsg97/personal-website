/** A blinking terminal block cursor. Blinking is disabled under reduced-motion. */
export function Cursor() {
  return <span className="cursor" aria-hidden="true" />;
}
