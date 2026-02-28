#pragma once

#include <QObject>
#include <QString>

class AppConfig : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString username READ username NOTIFY configChanged)
    Q_PROPERTY(QString profileImage READ profileImage NOTIFY configChanged)

public:
    explicit AppConfig(QObject *parent = nullptr);

    QString username() const;
    QString profileImage() const;

    Q_INVOKABLE void reload();

signals:
    void configChanged();

private:
    void load();

    QString m_username;
    QString m_profileImage;
};
