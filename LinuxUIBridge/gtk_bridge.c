#include <gtk/gtk.h>

static GtkApplication *app = NULL;

static void activate(GtkApplication *app, gpointer user_data) {
    GtkWidget *window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), "GTK4 from Rust via C");
    gtk_window_set_default_size(GTK_WINDOW(window), 300, 100);

    GtkWidget *label = gtk_label_new("✅ Window with GTK4 via dynamic library!");
    gtk_window_set_child(GTK_WINDOW(window), label);

    gtk_window_present(GTK_WINDOW(window));
}

void show_gtk_window() {
    if (app == NULL) {
        app = gtk_application_new("com.example.GtkRustBridge", G_APPLICATION_FLAGS_NONE);
        g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
        g_application_run(G_APPLICATION(app), 0, NULL);
        g_object_unref(app);
        app = NULL;
    }
}
