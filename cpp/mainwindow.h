#ifndef MAINWINDOW_H
#define MAINWINDOW_H

// ============================================================
// Приложение «Парикмахерская» (Qt / C++)
// ЛР №6 — Технологии доступа к базам данных
// Зависимость: Qt SQL module (QPSQL driver)
// ============================================================

#include <QMainWindow>
#include <QTableWidget>
#include <QPushButton>
#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QFormLayout>
#include <QMenu>
#include <QInputDialog>
#include <QMessageBox>
#include <QDialog>
#include <QLineEdit>
#include <QLabel>
#include <QSqlDatabase>
#include <QSqlQuery>
#include <QSqlError>
#include <QSqlRecord>

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void connectToDatabase();
    void showTablesMenu();
    void loadTable(const QString &tableName);
    void showSearchMenu();
    void searchClientBySurname();
    void searchServicesByPrice();
    void addMaster();
    void deleteVisit();

private:
    void initializeUI();
    bool initDatabase();
    void fillTableFromQuery(QSqlQuery &query);

    QTableWidget *tableWidget;
    QPushButton  *btnConnect;
    QPushButton  *btnTables;
    QPushButton  *btnSearch;
    QPushButton  *btnAddMaster;
    QPushButton  *btnDeleteVisit;
    QSqlDatabase  db;
};

#endif // MAINWINDOW_H
