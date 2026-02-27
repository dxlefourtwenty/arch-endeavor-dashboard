#pragma once
#include <QObject>
#include <QUrl>

class AppConfig : public QObject {
    Q_OBJECT
    Q_PROPERTY(QString username READ username CONSTANT)
    Q_PROPERTY(QUrl profileImage READ profileImage NOTIFY profileImageChanged)

public:
    explicit AppConfig(QObject *parent = nullptr);

    QString username() const { return m_username; }
    QUrl profileImage() const { return m_profile; }

public slots:
    void rescanProfileImage();

signals:
    void profileImageChanged();

private:
    QString m_username = "dxlefourtwenty";
    QUrl m_profile;

    QUrl findProfileImage() const;
};
