(function () {
  'use strict';

  const { base, title, branches } = DIFF_DATA;
  const branchNames = Object.keys(branches);
  const staging = document.getElementById('diff-staging');
  const cache = {};

  document.title = title;
  document.getElementById('page-title').textContent = title;
  document.getElementById('base-label').textContent = base;

  const select = document.getElementById('branch-select');
  branchNames.forEach(function (name) {
    const opt = document.createElement('option');
    opt.value = name;
    opt.textContent = name;
    select.appendChild(opt);
  });

  function renderBranchDiff(name) {
    const diff = branches[name];

    if (!diff || !diff.trim()) {
      return {
        left: mkMessage('No files changed vs ' + base),
        right: mkMessage('Identical to ' + base),
      };
    }

    const html = Diff2Html.html(diff, {
      drawFileList: false,
      matching: 'lines',
      outputFormat: 'side-by-side',
    });

    staging.innerHTML = html;

    const leftEl = document.createElement('div');
    const rightEl = document.createElement('div');

    staging.querySelectorAll('.d2h-file-wrapper').forEach(function (wrapper) {
      const header = wrapper.querySelector('.d2h-file-header');
      const sides = wrapper.querySelectorAll('.d2h-file-side-diff');
      if (!sides || sides.length < 2) return;

      [leftEl, rightEl].forEach(function (container, i) {
        const w = document.createElement('div');
        w.className = 'd2h-file-wrapper';
        if (header) w.appendChild(header.cloneNode(true));
        const fd = document.createElement('div');
        fd.className = 'd2h-files-diff';
        fd.appendChild(sides[i].cloneNode(true));
        w.appendChild(fd);
        container.appendChild(w);
      });
    });

    staging.innerHTML = '';
    return { left: leftEl, right: rightEl };
  }

  function mkMessage(msg) {
    const div = document.createElement('div');
    div.className = 'empty-state';
    div.textContent = msg;
    return div;
  }

  function showBranch(name) {
    if (!cache[name]) cache[name] = renderBranchDiff(name);

    const { left, right } = cache[name];
    const lc = document.getElementById('left-content');
    const rc = document.getElementById('right-content');

    lc.innerHTML = '';
    rc.innerHTML = '';
    lc.appendChild(left.cloneNode(true));
    rc.appendChild(right.cloneNode(true));

    document.getElementById('branch-label').textContent = name;
    lc.scrollTop = 0;
    rc.scrollTop = 0;
  }

  var syncing = false;
  var lc = document.getElementById('left-content');
  var rc = document.getElementById('right-content');

  function syncScroll(source, target) {
    if (syncing) return;
    syncing = true;
    target.scrollTop = source.scrollTop;
    syncing = false;
  }

  lc.addEventListener('scroll', function () { syncScroll(lc, rc); });
  rc.addEventListener('scroll', function () { syncScroll(rc, lc); });

  select.addEventListener('change', function () { showBranch(select.value); });

  if (branchNames.length > 0) showBranch(branchNames[0]);
}());
