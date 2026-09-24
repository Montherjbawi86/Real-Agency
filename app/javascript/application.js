// ============================================================
// NAVBAR DRAWER
// ============================================================
function setupNavbar() {
  const hamburger = document.getElementById("nav-hamburger");
  const drawer    = document.getElementById("nav-drawer");
  const backdrop  = document.getElementById("nav-drawer-backdrop");
  const closeBtn  = document.getElementById("nav-drawer-close");
  if (!hamburger || !drawer) return;

  const open  = () => {
    drawer.classList.add("open");
    backdrop.classList.add("show");
    document.body.classList.add("nav-drawer-open");
  };
  const close = () => {
    drawer.classList.remove("open");
    backdrop.classList.remove("show");
    document.body.classList.remove("nav-drawer-open");
  };

  hamburger.addEventListener("click", open);
  closeBtn?.addEventListener("click", close);
  backdrop?.addEventListener("click", close);
  document.addEventListener("keydown", (e) => { if (e.key === "Escape") close(); });
  drawer.querySelectorAll("a").forEach((l) => l.addEventListener("click", close));
}

// ============================================================
// DASHBOARD SIDEBAR DRAWER
// ============================================================
function setupDashboardSidebar() {
  const toggle   = document.getElementById("dash-sidebar-toggle");
  const sidebar  = document.getElementById("dash-sidebar");
  const backdrop = document.getElementById("dash-sidebar-backdrop");
  if (!toggle || !sidebar) return;

  toggle.addEventListener("click", () => {
    sidebar.classList.toggle("open");
    backdrop?.classList.toggle("show");
  });
  backdrop?.addEventListener("click", () => {
    sidebar.classList.remove("open");
    backdrop?.classList.remove("show");
  });
}

document.addEventListener("turbo:load", () => {
  setupNavbar();
  setupDashboardSidebar();
});
document.addEventListener("DOMContentLoaded", () => {
  setupNavbar();
  setupDashboardSidebar();
});
