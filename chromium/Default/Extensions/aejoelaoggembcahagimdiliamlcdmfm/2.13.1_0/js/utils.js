/*
 * Copyright 2010-2017 Restlet S.A.S. All rights reserved.
 * Restlet is registered trademark of Restlet S.A.S.
 */

!function () {
  'use strict';

  const KEYS = {
    UP: 38,
    DOWN: 40
  };

  window.RESTLET.utils = {
    scrollSmoothlyTo: scrollSmoothlyTo,
    scrollIntoContainerView: scrollIntoContainerView,
    KEYS: KEYS
  };

  function scrollSmoothlyTo (origin, to, durationInMS) {
    if (durationInMS <= 0) {
      return;
    }

    const differenceX = to.offsetLeft - origin.scrollLeft;
    const differenceY = to.offsetTop - origin.scrollTop;
    const perTickX = differenceX / durationInMS * 10;
    const perTickY = differenceY / durationInMS * 10;

    setTimeout(function () {
      origin.scrollLeft = origin.scrollLeft + perTickX;
      origin.scrollTop = origin.scrollTop + perTickY;
      if (origin.scrollTop === to) {
        return;
      }

      scrollSmoothlyTo(origin, to, durationInMS - 10);
    }, 10);
  }

  function scrollIntoContainerView (element, classOfContainer) {
    if (!element) {
      return;
    }

    // need to wrap that call into a setTimeout to make sure the dom has finished to render
    setTimeout(function () {
      const scrollableContainer = $('.' + classOfContainer);
      const scrollableHeight = scrollableContainer.height();
      const min = scrollableContainer.offset().top;
      const max = min + scrollableHeight;
      const elTop = $(element).offset().top;

      if (elTop <= min || elTop >= max) {
        scrollableContainer.animate({
          scrollTop: elTop - min + scrollableContainer.scrollTop() - (scrollableHeight / 2)
        }, 800);
      }
    }, 0);
  }

}();
