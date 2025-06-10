import { cn } from '../lib/utils'

import type React from 'react'

interface SectionContainerProps {
  children: React.ReactNode
  className?: string
  as?: React.ElementType
}

/**
 * A reusable container component that provides consistent responsive padding
 * and container styling across all sections.
 */
export function SectionContainer({
  children,
  className = '',
  as: Component = 'div',
}: SectionContainerProps) {
  return (
    <Component className={cn('container px-4 sm:px-6 lg:px-8', className)}>{children}</Component>
  )
}
