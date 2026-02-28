#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QObject>
#include <QFileSystemWatcher>
#include <QTimer>
#include <QDir>
#include <csignal>
#include <QQmlContext>
#include "systeminfo.h"
#include "appconfig.h"

static QObject *g_root = nullptr;

static void onSigUsr1(int)
{
    if (!g_root) return;

    QMetaObject::invokeMethod(
        g_root,
        "toggle",
        Qt::QueuedConnection
    );
}

int main(int argc, char *argv[])
{
    qputenv("QML_XHR_ALLOW_FILE_READ", "1");

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;
    SystemInfo sys;
    AppConfig cfg;

    engine.rootContext()->setContextProperty("SystemInfo", &sys);
    engine.rootContext()->setContextProperty("AppConfig", &cfg);
    engine.loadFromModule("TopDash", "Main");

    if (engine.rootObjects().isEmpty())
        return -1;

    QObject *root = engine.rootObjects().first();
    g_root = root;

    std::signal(SIGUSR1, onSigUsr1);

    QString themePath =
        QDir::homePath() + "/.config/dashboard/theme.qml";

    QFileInfo info(themePath);

    QString realPath = info.canonicalFilePath();

    QFileSystemWatcher *watcher =
        new QFileSystemWatcher({realPath});

    // debounce timer (important for symlink swaps)
    QTimer *reloadTimer = new QTimer;
    reloadTimer->setSingleShot(true);

    QObject::connect(
        watcher,
        &QFileSystemWatcher::fileChanged,
        [watcher, themePath, reloadTimer]() {

            QFileInfo info(themePath);
            QString newReal = info.canonicalFilePath();

            watcher->addPath(newReal);   // reattach watcher
            reloadTimer->start(80);
        }
    );

    QObject::connect(
        reloadTimer,
        &QTimer::timeout,
        [root]() {
            QMetaObject::invokeMethod(
                root,
                "reloadTheme",
                Qt::QueuedConnection
            );
        }
    );

    return app.exec();
}
