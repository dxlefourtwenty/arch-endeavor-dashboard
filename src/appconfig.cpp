#include "appconfig.h"

#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QStandardPaths>

AppConfig::AppConfig(QObject *parent)
    : QObject(parent)
{
    load();
}

QString AppConfig::username() const
{
    return m_username;
}

QString AppConfig::profileImage() const
{
    return m_profileImage;
}

void AppConfig::reload()
{
    load();
    emit configChanged();
}

void AppConfig::load()
{
    QString path =
        QStandardPaths::writableLocation(
            QStandardPaths::HomeLocation)
        + "/.config/dashboard/config.json";

    QFile file(path);
    if (!file.open(QIODevice::ReadOnly))
        return;

    auto doc = QJsonDocument::fromJson(file.readAll());
    auto obj = doc.object();

    m_username = obj["username"].toString("user");
    m_profileImage = obj["profileImage"].toString("");
}
