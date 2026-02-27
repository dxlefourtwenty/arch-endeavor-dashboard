#include "systeminfo.h"
#include <QFile>
#include <QTextStream>
#include <QProcess>
#include <sys/statvfs.h>

SystemInfo::SystemInfo(QObject *parent) : QObject(parent) {
    auto *t = new QTimer(this);
    t->setInterval(1000);
    connect(t, &QTimer::timeout, this, &SystemInfo::refresh);
    t->start();
    refresh();
}

static bool readFirstLine(const QString &path, QString &out) {
    QFile f(path);
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) return false;
    out = QString::fromUtf8(f.readLine()).trimmed();
    return true;
}

int SystemInfo::readCpuPercent() {
    QString line;
    if (!readFirstLine("/proc/stat", line)) return m_cpu;

    // cpu  user nice system idle iowait irq softirq steal ...
    QTextStream ts(&line);
    QString cpuLabel;
    quint64 user=0,nice=0,system=0,idle=0,iowait=0,irq=0,softirq=0,steal=0;
    ts >> cpuLabel >> user >> nice >> system >> idle >> iowait >> irq >> softirq >> steal;
    quint64 idleAll = idle + iowait;
    quint64 nonIdle = user + nice + system + irq + softirq + steal;
    quint64 total = idleAll + nonIdle;

    if (m_prevTotal == 0) { // first sample
        m_prevTotal = total;
        m_prevIdle = idleAll;
        return m_cpu;
    }

    quint64 totald = total - m_prevTotal;
    quint64 idled  = idleAll - m_prevIdle;
    m_prevTotal = total;
    m_prevIdle = idleAll;

    if (totald == 0) return m_cpu;
    double usage = (double)(totald - idled) / (double)totald * 100.0;
    int pct = (int)(usage + 0.5);
    if (pct < 0) pct = 0;
    if (pct > 100) pct = 100;
    return pct;
}

int SystemInfo::readDiskPercent() {
    struct statvfs s{};
    if (statvfs("/", &s) != 0) return m_disk;

    // percent used = 1 - (free blocks for unprivileged / total)
    double total = (double)s.f_blocks;
    double free  = (double)s.f_bavail;
    if (total <= 0) return m_disk;

    double usedPct = (1.0 - (free / total)) * 100.0;
    int pct = (int)(usedPct + 0.5);
    if (pct < 0) pct = 0;
    if (pct > 100) pct = 100;
    return pct;
}

int SystemInfo::readGpuPercent() {
    // Try NVIDIA first
    {
        QProcess p;
        p.start("nvidia-smi", {"--query-gpu=utilization.gpu", "--format=csv,noheader,nounits"});
        if (p.waitForFinished(150) && p.exitStatus() == QProcess::NormalExit && p.exitCode() == 0) {
            bool ok=false;
            int v = QString::fromUtf8(p.readAllStandardOutput()).trimmed().toInt(&ok);
            if (ok) return std::clamp(v, 0, 100);
        }
    }

    // Try common sysfs busy percent (works on many Intel/AMD setups depending on driver)
    QString line;
    if (readFirstLine("/sys/class/drm/card0/device/gpu_busy_percent", line)) {
        bool ok=false;
        int v = line.toInt(&ok);
        if (ok) return std::clamp(v, 0, 100);
    }

    return 0; // fallback
}

void SystemInfo::refresh() {
    int newCpu = readCpuPercent();
    int newGpu = readGpuPercent();
    int newDisk = readDiskPercent();

    if (newCpu != m_cpu) { m_cpu = newCpu; emit cpuPercentChanged(); }
    if (newGpu != m_gpu) { m_gpu = newGpu; emit gpuPercentChanged(); }
    if (newDisk != m_disk) { m_disk = newDisk; emit diskPercentChanged(); }
}
