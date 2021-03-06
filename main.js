const http = require('http');
const fs = require('fs');
const electron = require('electron');
// Module to control application life.
const {app,globalShortcut,ipcMain,dialog,Menu} = electron;
// Module to create native browser window.
const BrowserWindow = electron.BrowserWindow;

// Keep a global reference of the window object, if you don't, the window will
// be closed automatically when the JavaScript object is garbage collected.
let mainWindow;
const template = [
  {
    role: 'help',
    submenu: [
      {
        role: 'about',
        click () { 
          dialog.showMessageBox({ message: 
          "الأصدار: 0.0.2\n"+
          "بواسطة: xlmnxp\n"+
          "للمزيد من المعلومات قم بزيارت المنتدى التالي\n"+
          "http://www.mofaker.ga/vb/"
          ,type:"info" })
         }
      }
    ]
  }
]

function createWindow () {
  // Create the browser window.
  mainWindow = new BrowserWindow({});
  const menu = Menu.buildFromTemplate(template);
  Menu.setApplicationMenu(menu);
  mainWindow.setMenu(menu);
  mainWindow.loadURL(`file://${__dirname}/index.html`);
  //mainWindow.webContents.openDevTools()

  // Emitted when the window is closed.
  mainWindow.on('closed', function () {
    // Dereference the window object, usually you would store windows
    // in an array if your app supports multi windows, this is the time
    // when you should delete the corresponding element.
    mainWindow = null
  });
}

// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.on('ready', createWindow)

// Quit when all windows are closed.
app.on('window-all-closed', function () {
  // On OS X it is common for applications and their menu bar
  // to stay active until the user quits explicitly with Cmd + Q
  if (process.platform !== 'darwin') {
    app.quit()
  }
})

app.on('ready', () => {

});

// app.on('will-quit', () => {
//   // Unregister a shortcut.
//   globalShortcut.unregister('Home');
//   globalShortcut.unregister('Escape');
//
//   // Unregister all shortcuts.
//   globalShortcut.unregisterAll();
// });

app.on('browser-window-created',function(e,window) {
      window.setMenu(null);
});

app.on('activate', function () {
  // On OS X it's common to re-create a window in the app when the
  // dock icon is clicked and there are no other windows open.
  if (mainWindow === null) {
    createWindow()
  }
})
