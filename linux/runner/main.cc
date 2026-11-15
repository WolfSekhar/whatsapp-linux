#include "my_application.h"

int main(int argc, char** argv) {
  // Enforce Wayland native backend on Linux desktop environments
  g_setenv("GDK_BACKEND", "wayland", FALSE);

  g_autoptr(MyApplication) app = my_application_new();
  return g_application_run(G_APPLICATION(app), argc, argv);
}

