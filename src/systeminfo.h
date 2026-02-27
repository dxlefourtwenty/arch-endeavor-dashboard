#pragma once
#include <QObject>
#include <QTimer>

class SystemInfo : public QObject {
    Q_OBJECT
    Q_PROPERTY(int cpuPercent READ cpuPercent NOTIFY cpuPercentChanged)
    Q_PROPERTY(int gpuPercent READ gpuPercent NOTIFY gpuPercentChanged)
    Q_PROPERTY(int diskPercent READ diskPercent NOTIFY diskPercentChanged)

public:
    explicit SystemInfo(QObject *parent = nullptr);

    int cpuPercent() const { return m_cpu; }
    int gpuPercent() const { return m_gpu; }
    int diskPercent() const { return m_disk; }

public slots:
    void refresh();

signals:
    void cpuPercentChanged();
    void gpuPercentChanged();
    void diskPercentChanged();

private:
    int m_cpu = 0;
    int m_gpu = 0;
    int m_disk = 0;

    quint64 m_prevTotal = 0;
    quint64 m_prevIdle = 0;

    int readCpuPercent();
    int readDiskPercent();   // "/" usage
    int readGpuPercent();    // best-effort
};
