"""
enum v4l2_buf_type {
    V4L2_BUF_TYPE_VIDEO_CAPTURE        = 1,
    V4L2_BUF_TYPE_VIDEO_OUTPUT         = 2,
    V4L2_BUF_TYPE_VIDEO_OVERLAY        = 3,
    V4L2_BUF_TYPE_VBI_CAPTURE          = 4,
    V4L2_BUF_TYPE_VBI_OUTPUT           = 5,
    V4L2_BUF_TYPE_SLICED_VBI_CAPTURE   = 6,
    V4L2_BUF_TYPE_SLICED_VBI_OUTPUT    = 7,
    V4L2_BUF_TYPE_VIDEO_OUTPUT_OVERLAY = 8,
    V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE = 9,
    V4L2_BUF_TYPE_VIDEO_OUTPUT_MPLANE  = 10,
    V4L2_BUF_TYPE_SDR_CAPTURE          = 11,
    V4L2_BUF_TYPE_SDR_OUTPUT           = 12,
    V4L2_BUF_TYPE_META_CAPTURE         = 13,
    V4L2_BUF_TYPE_META_OUTPUT          = 14,
    /*
     * Note: V4L2_TYPE_IS_VALID and V4L2_TYPE_IS_OUTPUT must
     * be updated if a new type is added.
     */
    /* Deprecated, do not use */
    V4L2_BUF_TYPE_PRIVATE              = 0x80,
};
"""

from enum import IntEnum
from .import IoctlEnum, _IOR, _IOW, _IOWR

V4L2_BUFFER_SIZEOF = 88

#define VIDIOC_DQBUF		_IOWR('V', 17, struct v4l2_buffer)
class Vidioc(IoctlEnum):
    @classmethod
    def prefix(cls) -> str:
        return "VIDIOC_"

    DQBUF = _IOR('V', 17, V4L2_BUFFER_SIZEOF)


class V4l2BufType(IntEnum):
    """
    V4L2_BUF_TYPE_VIDEO_CAPTURE
    V4L2_BUF_TYPE_VIDEO_OUTPUT
    V4L2_BUF_TYPE_VIDEO_OVERLAY
    V4L2_BUF_TYPE_VBI_CAPTURE
    V4L2_BUF_TYPE_VBI_OUTPUT
    V4L2_BUF_TYPE_SLICED_VBI_CAPTURE
    V4L2_BUF_TYPE_SLICED_VBI_OUTPUT
    V4L2_BUF_TYPE_VIDEO_OUTPUT_OVERLAY
    V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE
    V4L2_BUF_TYPE_VIDEO_OUTPUT_MPLANE
    V4L2_BUF_TYPE_SDR_CAPTURE
    V4L2_BUF_TYPE_SDR_OUTPUT
    V4L2_BUF_TYPE_META_CAPTURE
    V4L2_BUF_TYPE_META_OUTPUT

    # Deprecated, do not use.
    V4L2_BUF_TYPE_PRIVATE
    """

    # The one we want.
    V4L2_BUF_TYPE_VIDEO_CAPTURE        = 1
    V4L2_BUF_TYPE_VIDEO_OUTPUT         = 2
    V4L2_BUF_TYPE_VIDEO_OVERLAY        = 3
    V4L2_BUF_TYPE_VBI_CAPTURE          = 4
    V4L2_BUF_TYPE_VBI_OUTPUT           = 5
    V4L2_BUF_TYPE_SLICED_VBI_CAPTURE   = 6
    V4L2_BUF_TYPE_SLICED_VBI_OUTPUT    = 7
    V4L2_BUF_TYPE_VIDEO_OUTPUT_OVERLAY = 8
    V4L2_BUF_TYPE_VIDEO_CAPTURE_MPLANE = 9
    V4L2_BUF_TYPE_VIDEO_OUTPUT_MPLANE  = 10
    V4L2_BUF_TYPE_SDR_CAPTURE          = 11
    V4L2_BUF_TYPE_SDR_OUTPUT           = 12
    V4L2_BUF_TYPE_META_CAPTURE         = 13
    V4L2_BUF_TYPE_META_OUTPUT          = 14

    # Deprecated, do not use.
    V4L2_BUF_TYPE_PRIVATE              = 0x80

"""
/*
 * Used to create numbers.
 *
 * NOTE: _IOW means userland is writing and kernel is reading. _IOR
 * means userland is reading and kernel is writing.
 */
#define _IO(type,nr)			_IOC(_IOC_NONE,(type),(nr),0)
#define _IOR(type,nr,argtype)		_IOC(_IOC_READ,(type),(nr),(_IOC_TYPECHECK(argtype)))
#define _IOW(type,nr,argtype)		_IOC(_IOC_WRITE,(type),(nr),(_IOC_TYPECHECK(argtype)))
#define _IOWR(type,nr,argtype)		_IOC(_IOC_READ|_IOC_WRITE,(type),(nr),(_IOC_TYPECHECK(argtype)))
#define _IOR_BAD(type,nr,argtype)	_IOC(_IOC_READ,(type),(nr),sizeof(argtype))
#define _IOW_BAD(type,nr,argtype)	_IOC(_IOC_WRITE,(type),(nr),sizeof(argtype))
#define _IOWR_BAD(type,nr,argtype)	_IOC(_IOC_READ|_IOC_WRITE,(type),(nr),sizeof(argtype))

/* used to decode ioctl numbers.. */
#define _IOC_DIR(nr)		(((nr) >> _IOC_DIRSHIFT) & _IOC_DIRMASK)
#define _IOC_TYPE(nr)		(((nr) >> _IOC_TYPESHIFT) & _IOC_TYPEMASK)
#define _IOC_NR(nr)		(((nr) >> _IOC_NRSHIFT) & _IOC_NRMASK)
#define _IOC_SIZE(nr)		(((nr) >> _IOC_SIZESHIFT) & _IOC_SIZEMASK)

/* ...and for the drivers/sound files... */

#define IOC_IN		(_IOC_WRITE << _IOC_DIRSHIFT)
#define IOC_OUT		(_IOC_READ << _IOC_DIRSHIFT)
#define IOC_INOUT	((_IOC_WRITE|_IOC_READ) << _IOC_DIRSHIFT)
#define IOCSIZE_MASK	(_IOC_SIZEMASK << _IOC_SIZESHIFT)
#define IOCSIZE_SHIFT	(_IOC_SIZESHIFT)
"""

"""
/*
 * The following is for compatibility across the various Linux
 * platforms.  The generic ioctl numbering scheme doesn't really enforce
 * a type field.  De facto, however, the top 8 bits of the lower 16
 * bits are indeed used as a type field, so we might just as well make
 * this explicit here.  Please be sure to use the decoding macros
 * below from now on.
 */
#define _IOC_NRBITS	8
#define _IOC_TYPEBITS	8

/*
 * Let any architecture override either of the following before
 * including this file.
 */

#ifndef _IOC_SIZEBITS
# define _IOC_SIZEBITS	14
#endif

#ifndef _IOC_DIRBITS
# define _IOC_DIRBITS	2
#endif

#define _IOC_NRMASK	((1 << _IOC_NRBITS)-1)
#define _IOC_TYPEMASK	((1 << _IOC_TYPEBITS)-1)
#define _IOC_SIZEMASK	((1 << _IOC_SIZEBITS)-1)
#define _IOC_DIRMASK	((1 << _IOC_DIRBITS)-1)

#define _IOC_NRSHIFT	0
#define _IOC_TYPESHIFT	(_IOC_NRSHIFT+_IOC_NRBITS)
#define _IOC_SIZESHIFT	(_IOC_TYPESHIFT+_IOC_TYPEBITS)
#define _IOC_DIRSHIFT	(_IOC_SIZESHIFT+_IOC_SIZEBITS)

/*
 * Direction bits, which any architecture can choose to override
 * before including this file.
 *
 * NOTE: _IOC_WRITE means userland is writing and kernel is
 * reading. _IOC_READ means userland is reading and kernel is writing.
 */

#ifndef _IOC_NONE
# define _IOC_NONE	0U
#endif

#ifndef _IOC_WRITE
# define _IOC_WRITE	1U
#endif

#ifndef _IOC_READ
# define _IOC_READ	2U
#endif

#define _IOC(dir,type,nr,size) \
	(((dir)  << _IOC_DIRSHIFT) | \
	 ((type) << _IOC_TYPESHIFT) | \
	 ((nr)   << _IOC_NRSHIFT) | \
	 ((size) << _IOC_SIZESHIFT))

"""
