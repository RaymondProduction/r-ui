#include <gtk/gtk.h>

static GtkApplication *app = NULL;
static char *stored_message = NULL;

static void activate(GtkApplication *app, gpointer user_data) {
    GtkWidget *window = gtk_application_window_new(app);
    gtk_window_set_title(GTK_WINDOW(window), "GTK4: Message from Rust");
    gtk_window_set_default_size(GTK_WINDOW(window), 400, 120);

    GtkWidget *label = gtk_label_new(stored_message ? stored_message : "⚠️ No message");
    gtk_window_set_child(GTK_WINDOW(window), label);

    gtk_window_present(GTK_WINDOW(window));
}

// This function is called from Rust
void show_gtk_window_with_text(const char *text) {
    if (stored_message) {
        g_free(stored_message);
        stored_message = NULL;
    }

    if (text) {
        stored_message = g_strdup(text); // Store text on the heap
    }

    if (app == NULL) {
        app = gtk_application_new("com.example.GtkRustBridge", G_APPLICATION_FLAGS_NONE);
        g_signal_connect(app, "activate", G_CALLBACK(activate), NULL);
        g_application_run(G_APPLICATION(app), 0, NULL);
        g_object_unref(app);
        app = NULL;
    }
}
