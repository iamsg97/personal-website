import { useIntersectionObserver } from '../hooks/useIntersectionObserver'
import { cn } from '../lib/utils'

interface AnimatedSectionProps {
  children: React.ReactNode
  className?: string
  delay?: number
  as?: React.ElementType
  animation?: 'zoom' | 'slideUp' | 'slideInLeft' | 'slideInRight' | 'fade'
}

export function AnimatedSection({
  children,
  className = '',
  delay = 0,
  as: Component = 'div',
  animation = 'zoom',
}: AnimatedSectionProps) {
  const { ref, isVisible } = useIntersectionObserver({
    threshold: 0.1,
    rootMargin: '0px 0px -50px 0px',
    triggerOnce: true,
  })

  const getAnimationClasses = () => {
    const baseClasses = 'transition-all duration-700 ease-out'

    switch (animation) {
      case 'zoom':
        return cn(
          baseClasses,
          isVisible ? 'opacity-100 scale-100 transform' : 'opacity-0 scale-95 transform',
        )
      case 'slideUp':
        return cn(
          baseClasses,
          isVisible ? 'opacity-100 translate-y-0 transform' : 'opacity-0 translate-y-8 transform',
        )
      case 'slideInLeft':
        return cn(
          baseClasses,
          isVisible ? 'opacity-100 translate-x-0 transform' : 'opacity-0 -translate-x-8 transform',
        )
      case 'slideInRight':
        return cn(
          baseClasses,
          isVisible ? 'opacity-100 translate-x-0 transform' : 'opacity-0 translate-x-8 transform',
        )
      case 'fade':
        return cn(baseClasses, isVisible ? 'opacity-100' : 'opacity-0')
      default:
        return baseClasses
    }
  }

  return (
    <Component
      ref={ref}
      className={cn(getAnimationClasses(), className)}
      style={{
        transitionDelay: `${delay}ms`,
      }}
    >
      {children}
    </Component>
  )
}
