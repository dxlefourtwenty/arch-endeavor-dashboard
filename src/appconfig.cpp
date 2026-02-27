#include "appconfig.h"
#include <QDir>
#include <QFileInfo>

AppConfig::AppConfig(QObject *parent) : QObject(parent) {
    m_profile = findProfileImage();
}

QUrl AppConfig::findProfileImage() const {
    const QString base = QDir::homePath() + "/bin/images/profile-picture";
    const QStringList exts = {"png", "jpg", "jpeg", "svg"};

    for (const auto &ext : exts) {
        QString path = base + "." + ext;
        if (QFileInfo::exists(path))
            return QUrl::fromLocalFile(path);
    }
    return QUrl(); // empty
}

void AppConfig::rescanProfileImage() {
    QUrl next = findProfileImage();
    if (next != m_profile) {
        m_profile = next;
        emit profileImageChanged();
    }
}
