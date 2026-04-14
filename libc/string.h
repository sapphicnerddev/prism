// Freestanding implementations of the stdlib C string/memory functions
// Very nice for prism, especially since we intentionally avoid -lc and -lstdc++

#ifndef _LIBC_STRING_H
#define _LIBC_STRING_H

typedef __SIZE_TYPE__ size_t;

#ifndef NULL
#define NULL ((void *)0)
#endif

// ── mem functions ────────────────────────────────────────────────────────────

static inline void *memset(void *s, int c, size_t n)
{
    unsigned char *p = (unsigned char *)s;
    while (n--)
        *p++ = (unsigned char)c;
    return s;
}

static inline void *memcpy(void *__restrict__ dst, const void *__restrict__ src, size_t n)
{
    unsigned char *d = (unsigned char *)dst;
    const unsigned char *s = (const unsigned char *)src;
    while (n--)
        *d++ = *s++;
    return dst;
}

static inline void *memmove(void *dst, const void *src, size_t n)
{
    unsigned char *d = (unsigned char *)dst;
    const unsigned char *s = (const unsigned char *)src;
    if (d < s) {
        while (n--)
            *d++ = *s++;
    } else if (d > s) {
        d += n;
        s += n;
        while (n--)
            *--d = *--s;
    }
    return dst;
}

static inline int memcmp(const void *s1, const void *s2, size_t n)
{
    const unsigned char *a = (const unsigned char *)s1;
    const unsigned char *b = (const unsigned char *)s2;
    while (n--) {
        if (*a != *b)
            return (int)*a - (int)*b;
        a++;
        b++;
    }
    return 0;
}

static inline void *memchr(const void *s, int c, size_t n)
{
    const unsigned char *p = (const unsigned char *)s;
    unsigned char uc = (unsigned char)c;
    while (n--) {
        if (*p == uc)
            return (void *)p;
        p++;
    }
    return NULL;
}

// ── str functions ────────────────────────────────────────────────────────────

static inline size_t strlen(const char *s) 
{
    const char *p = s;
    while (*p)
        p++;
    return (size_t)(p - s);
}

static inline int strcmp(const char *s1, const char *s2)
{
    while (*s1 && *s1 == *s2) {
        s1++;
        s2++;
    }
    return (int)(unsigned char)*s1 - (int)(unsigned char)*s2;
}

static inline int strncmp(const char *s1, const char *s2, size_t n)
{
    while (n-- > 0) {
        if (*s1 != *s2)
            return (int)(unsigned char)*s1 - (int)(unsigned char)*s2;
        if (!*s1)
            break;
        s1++;
        s2++;
    }
    return 0;
}

static inline char *strcpy(char *__restrict__ dst, const char *__restrict__ src)
{
    char *d = dst;
    while ((*d++ = *src++))
        ;
    return dst;
}

static inline char *strncpy(char *__restrict__ dst, const char *__restrict__ src, size_t n)
{
    char *d = dst;
    while (n && *src) {
        *d++ = *src++;
        n--;
    }
    if (n) *d++ = '\0';
    while (--n > 0)
        *d++ = '\0';
    return dst;
}

static inline char *strcat(char *__restrict__ dst, const char *__restrict__ src)
{
    char *d = dst + strlen(dst);
    while ((*d++ = *src++))
        ;
    return dst;
}

static inline char *strncat(char *__restrict__ dst, const char *__restrict__ src, size_t n)
{
    char *d = dst + strlen(dst);
    while (n-- && *src)
        *d++ = *src++;
    *d = '\0';
    return dst;
}

static inline char *strchr(const char *s, int c)
{
    char ch = (char)c;
    while (*s) {
        if (*s == ch)
            return (char *)s;
        s++;
    }
    return (ch == '\0') ? (char *)s : (char *)NULL;
}

static inline char *strrchr(const char *s, int c)
{
    char ch = (char)c;
    const char *last = (const char *)NULL;
    while (*s) {
        if (*s == ch)
            last = s;
        s++;
    }
    if (ch == '\0')
        return (char *)s;
    return (char *)last;
}

#endif // _LIBC_STRING_H
