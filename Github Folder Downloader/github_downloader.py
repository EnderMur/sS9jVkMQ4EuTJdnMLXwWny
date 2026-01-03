#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import sys
import requests
import tkinter as tk
from tkinter import ttk, messagebox, filedialog
from pathlib import Path
import threading
import urllib.parse
import json
import time
class GitHubDownloader:
    def __init__(self, root):
        self.root = root
        self.root.title("GitHub Folder Downloader")
        self.root.geometry("700x550")
        
        self.downloaded_dir = Path("downloaded")
        self.downloaded_dir.mkdir(exist_ok=True)
        
        self.config_file = Path("config.json")
        self.config = self.load_config()
        
        self.setup_ui()
        
    def load_config(self):
        if self.config_file.exists():
            try:
                with open(self.config_file, 'r', encoding='utf-8') as f:
                    return json.load(f)
            except:
                return {}
        return {}
        
    def save_config(self):
        try:
            with open(self.config_file, 'w', encoding='utf-8') as f:
                json.dump(self.config, f, indent=2, ensure_ascii=False)
        except Exception as e:
            self.log(f"⚠ Не удалось сохранить конфиг: {e}")
            
    def setup_token_context_menu(self):
        menu = tk.Menu(self.token_entry, tearoff=0)
        
        def paste():
            try:
                try:
                    self.token_entry.delete(tk.SEL_FIRST, tk.SEL_LAST)
                except:
                    pass
                clipboard_content = self.root.clipboard_get()
                self.token_entry.insert(tk.INSERT, clipboard_content)
            except Exception as e:
                self.log(f"Ошибка вставки: {e}")
            
        def copy():
            try:
                self.root.clipboard_clear()
                self.root.clipboard_append(self.token_entry.get(tk.SEL_FIRST, tk.SEL_LAST))
            except:
                pass
                
        def cut():
            try:
                self.root.clipboard_clear()
                self.root.clipboard_append(self.token_entry.get(tk.SEL_FIRST, tk.SEL_LAST))
                self.token_entry.delete(tk.SEL_FIRST, tk.SEL_LAST)
            except:
                pass
                
        def select_all():
            self.token_entry.select_range(0, tk.END)
            self.token_entry.focus()
        
        menu.add_command(label="Вырезать", command=cut, accelerator="Ctrl+X")
        menu.add_command(label="Копировать", command=copy, accelerator="Ctrl+C")
        menu.add_command(label="Вставить", command=paste, accelerator="Ctrl+V")
        menu.add_separator()
        menu.add_command(label="Выделить всё", command=select_all, accelerator="Ctrl+A")
        
        def show_menu(event):
            menu.tk_popup(event.x_root, event.y_root)
            
        self.token_entry.bind("<Button-3>", show_menu)
        self.token_entry.bind("<Control-v>", lambda e: (paste(), "break"))
        self.token_entry.bind("<Control-V>", lambda e: (paste(), "break"))
        self.token_entry.bind("<Control-x>", lambda e: (cut(), "break"))
        self.token_entry.bind("<Control-X>", lambda e: (cut(), "break"))
        self.token_entry.bind("<Control-c>", lambda e: (copy(), "break"))
        self.token_entry.bind("<Control-C>", lambda e: (copy(), "break"))
        self.token_entry.bind("<Control-a>", lambda e: (select_all(), "break"))
        self.token_entry.bind("<Control-A>", lambda e: (select_all(), "break"))
        
    def setup_url_context_menu(self):
        menu = tk.Menu(self.url_entry, tearoff=0)
        
        def paste():
            try:
                try:
                    self.url_entry.delete(tk.SEL_FIRST, tk.SEL_LAST)
                except:
                    pass
                clipboard_content = self.root.clipboard_get()
                self.url_entry.insert(tk.INSERT, clipboard_content)
            except Exception as e:
                self.log(f"Ошибка вставки URL: {e}")
            
        def copy():
            try:
                self.root.clipboard_clear()
                self.root.clipboard_append(self.url_entry.get(tk.SEL_FIRST, tk.SEL_LAST))
            except:
                pass
                
        def cut():
            try:
                self.root.clipboard_clear()
                self.root.clipboard_append(self.url_entry.get(tk.SEL_FIRST, tk.SEL_LAST))
                self.url_entry.delete(tk.SEL_FIRST, tk.SEL_LAST)
            except:
                pass
                
        def select_all():
            self.url_entry.select_range(0, tk.END)
            self.url_entry.focus()
        
        menu.add_command(label="Вырезать", command=cut, accelerator="Ctrl+X")
        menu.add_command(label="Копировать", command=copy, accelerator="Ctrl+C")
        menu.add_command(label="Вставить", command=paste, accelerator="Ctrl+V")
        menu.add_separator()
        menu.add_command(label="Выделить всё", command=select_all, accelerator="Ctrl+A")
        
        def show_menu(event):
            menu.tk_popup(event.x_root, event.y_root)
            
        self.url_entry.bind("<Button-3>", show_menu)
        self.url_entry.bind("<Control-v>", lambda e: (paste(), "break"))
        self.url_entry.bind("<Control-V>", lambda e: (paste(), "break"))
        self.url_entry.bind("<Control-x>", lambda e: (cut(), "break"))
        self.url_entry.bind("<Control-X>", lambda e: (cut(), "break"))
        self.url_entry.bind("<Control-c>", lambda e: (copy(), "break"))
        self.url_entry.bind("<Control-C>", lambda e: (copy(), "break"))
        self.url_entry.bind("<Control-a>", lambda e: (select_all(), "break"))
        self.url_entry.bind("<Control-A>", lambda e: (select_all(), "break"))
        
    def paste_token(self):
        try:
            clipboard_content = self.root.clipboard_get()
            self.token_entry.delete(0, tk.END)
            self.token_entry.insert(0, clipboard_content)
            self.log("✓ Токен вставлен из буфера обмена")
        except Exception as e:
            messagebox.showerror("Ошибка", f"Не удалось вставить из буфера обмена: {e}")
            
    def paste_url(self):
        try:
            clipboard_content = self.root.clipboard_get()
            self.url_entry.delete(0, tk.END)
            self.url_entry.insert(0, clipboard_content)
            self.log("✓ URL вставлен из буфера обмена")
        except Exception as e:
            messagebox.showerror("Ошибка", f"Не удалось вставить URL из буфера обмена: {e}")
        
    def setup_ui(self):
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        ttk.Label(main_frame, text="GitHub Token:").grid(row=0, column=0, sticky=tk.W, pady=(0, 5))
        
        token_frame = ttk.Frame(main_frame)
        token_frame.grid(row=1, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 5))
        
        self.token_entry = ttk.Entry(token_frame, width=50)
        self.token_entry.pack(side=tk.LEFT, fill=tk.X, expand=True)
        
        self.setup_token_context_menu()
        
        paste_btn = ttk.Button(token_frame, text="Вставить", command=self.paste_token, width=8)
        paste_btn.pack(side=tk.RIGHT, padx=(5, 0))
        
        saved_token = self.config.get('token', '')
        if saved_token:
            self.token_entry.insert(0, saved_token)
            
        self.save_token_var = tk.BooleanVar(value=bool(saved_token))
        save_token_check = ttk.Checkbutton(main_frame, text="Сохранить токен", variable=self.save_token_var)
        save_token_check.grid(row=2, column=0, sticky=tk.W, pady=(0, 10))
        
        ttk.Label(main_frame, text="GitHub Folder URL:").grid(row=3, column=0, sticky=tk.W, pady=(0, 5))
        
        url_frame = ttk.Frame(main_frame)
        url_frame.grid(row=4, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 10))
        
        self.url_entry = ttk.Entry(url_frame, width=50)
        self.url_entry.pack(side=tk.LEFT, fill=tk.X, expand=True)
        
        paste_url_btn = ttk.Button(url_frame, text="Вставить", command=self.paste_url, width=8)
        paste_url_btn.pack(side=tk.RIGHT, padx=(5, 0))
        
        self.setup_url_context_menu()
        
        self.download_btn = ttk.Button(main_frame, text="Скачать папку", command=self.start_download)
        self.download_btn.grid(row=5, column=0, sticky=tk.W, pady=(0, 10))
        
        self.open_btn = ttk.Button(main_frame, text="Открыть downloaded", command=self.open_downloaded)
        self.open_btn.grid(row=5, column=1, sticky=tk.E, pady=(0, 10))
        
        self.progress = ttk.Progressbar(main_frame, mode='indeterminate')
        self.progress.grid(row=6, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 5))
        
        info_frame = ttk.Frame(main_frame)
        info_frame.grid(row=7, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 5))
        
        self.time_label = ttk.Label(info_frame, text="Время: 0.00с")
        self.time_label.pack(side=tk.LEFT, padx=(0, 20))
        
        self.speed_label = ttk.Label(info_frame, text="Скорость: 0 КБ/с")
        self.speed_label.pack(side=tk.LEFT, padx=(0, 20))
        
        self.files_label = ttk.Label(info_frame, text="Файлов: 0")
        self.files_label.pack(side=tk.LEFT)
        
        self.size_label = ttk.Label(info_frame, text="Размер: 0 КБ")
        self.size_label.pack(side=tk.LEFT, padx=(20, 0))
        
        ttk.Label(main_frame, text="Лог:").grid(row=8, column=0, sticky=tk.W, pady=(0, 5))
        self.log_text = tk.Text(main_frame, height=15, width=80)
        self.log_text.grid(row=9, column=0, columnspan=2, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        scrollbar = ttk.Scrollbar(main_frame, orient="vertical", command=self.log_text.yview)
        scrollbar.grid(row=9, column=2, sticky=(tk.N, tk.S))
        self.log_text.config(yscrollcommand=scrollbar.set)
        
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(0, weight=1)
        main_frame.rowconfigure(9, weight=1)
        
    def log(self, message):
        self.log_text.insert(tk.END, message + "\n")
        self.log_text.see(tk.END)
        self.root.update()
        
    def parse_github_url(self, url):
        url = url.rstrip('/')
        url = urllib.parse.unquote(url)
        
        if 'github.com/' not in url:
            raise ValueError("Неверный URL GitHub")
            
        parts = url.split('github.com/')[1].split('/')
        
        if len(parts) < 4:
            raise ValueError("Неверный формат URL")
            
        owner = parts[0]
        repo = parts[1]
        
        if len(parts) > 2 and parts[2] in ['tree', 'blob']:
            branch = parts[3] if len(parts) > 3 else 'main'
            path = '/'.join(parts[4:]) if len(parts) > 4 else ''
        else:
            branch = 'main'
            path = ''
            
        return owner, repo, branch, path
        
    def get_api_url(self, owner, repo, branch, path):
        if path:
            encoded_path = urllib.parse.quote(path, safe='/')
            return f"https://api.github.com/repos/{owner}/{repo}/contents/{encoded_path}?ref={branch}"
        else:
            return f"https://api.github.com/repos/{owner}/{repo}/contents?ref={branch}"
        
    def download_folder_recursive(self, api_url, local_path, headers):
        try:
            self.log(f"Запрос к API: {api_url}")
            response = requests.get(api_url, headers=headers)
            
            if response.status_code == 401:
                raise Exception("Неверный токен или недостаточно прав")
            elif response.status_code == 404:
                raise Exception("Папка или репозиторий не найдены")
            elif response.status_code != 200:
                raise Exception(f"Ошибка API: {response.status_code} - {response.text}")
                
            items = response.json()
            
            if not isinstance(items, list):
                items = [items]
                
            for item in items:
                item_name = item['name']
                item_type = item['type']
                item_download_url = item.get('download_url')
                item_path = item['path']
                
                if item_type == 'file':
                    if item_download_url:
                        self.log(f"Скачиваю файл: {item_name}")
                        file_response = requests.get(item_download_url, headers=headers)
                        if file_response.status_code == 200:
                            local_file_path = local_path / item_name
                            local_file_path.parent.mkdir(parents=True, exist_ok=True)
                            
                            content = file_response.content
                            file_size = len(content)
                            
                            with open(local_file_path, 'wb') as f:
                                f.write(content)
                            
                            self.total_bytes += file_size
                            self.total_files += 1
                            
                            self.log(f"✓ Сохранен: {item_name} ({file_size} байт)")
                        else:
                            self.log(f"✗ Ошибка скачивания файла {item_name}: {file_response.status_code}")
                            
                elif item_type == 'dir':
                    self.log(f"Вхожу в папку: {item_name}")
                    sub_local_path = local_path / item_name
                    sub_local_path.mkdir(parents=True, exist_ok=True)
                    
                    sub_api_url = self.get_api_url_from_item(item)
                    self.download_folder_recursive(sub_api_url, sub_local_path, headers)
                    
        except Exception as e:
            self.log(f"✗ Ошибка: {str(e)}")
            raise
            
    def get_api_url_from_item(self, item):
        if 'url' in item:
            return item['url']
        return f"https://api.github.com/repos/{item['repository']['full_name']}/contents/{item['path']}"
        
    def start_download(self):
        token = self.token_entry.get().strip()
        url = self.url_entry.get().strip()
        
        if not token:
            messagebox.showerror("Ошибка", "Введите GitHub token")
            return
            
        if not url:
            messagebox.showerror("Ошибка", "Введите URL папки GitHub")
            return
            
        if self.save_token_var.get():
            self.config['token'] = token
        else:
            self.config.pop('token', None)
        self.save_config()
            
        self.download_btn.config(state='disabled')
        self.open_btn.config(state='disabled')
        self.progress.start(10)
        
        self.log_text.delete(1.0, tk.END)
        self.log("Начинаю скачивание...")
        
        self.start_time = time.time()
        self.total_bytes = 0
        self.total_files = 0
        self.is_downloading = True
        
        # Запускаем обновление статистики
        self.update_stats()
        
        thread = threading.Thread(target=self.download_thread, args=(token, url))
        thread.daemon = True
        thread.start()
        
    def update_stats(self):
        """Обновление статистики в реальном времени"""
        if not self.is_downloading:
            return
            
        elapsed = time.time() - self.start_time
        if elapsed > 0:
            speed = self.total_bytes / elapsed / 1024
        else:
            speed = 0
            
        self.time_label.config(text=f"Время: {elapsed:.2f}с")
        self.speed_label.config(text=f"Скорость: {speed:.1f} КБ/с")
        self.files_label.config(text=f"Файлов: {self.total_files}")
        self.size_label.config(text=f"Размер: {self.total_bytes / 1024:.1f} КБ")
        
        # Продолжаем обновление каждые 0.1 секунды
        self.root.after(100, self.update_stats)
        
    def download_thread(self, token, url):
        try:
            self.log(f"Парсинг URL: {url}")
            owner, repo, branch, path = self.parse_github_url(url)
            self.log(f"Owner: {owner}, Repo: {repo}, Branch: {branch}, Path: {path}")
            
            if path:
                folder_name = path.split('/')[-1]
            else:
                folder_name = repo
                
            local_folder = self.downloaded_dir / folder_name
            local_folder.mkdir(exist_ok=True)
            self.log(f"Сохраняю в: {local_folder}")
            
            api_url = self.get_api_url(owner, repo, branch, path)
            self.log(f"API URL: {api_url}")
            
            headers = {
                'Authorization': f'token {token}',
                'Accept': 'application/vnd.github.v3+json'
            }
            
            self.download_folder_recursive(api_url, local_folder, headers)
            
            elapsed = time.time() - self.start_time
            speed = self.total_bytes / elapsed / 1024 if elapsed > 0 else 0
            
            self.log("\n✓ Скачивание завершено успешно!")
            self.log(f"Папка сохранена: {local_folder}")
            self.log(f"Всего файлов: {self.total_files}")
            self.log(f"Общий размер: {self.total_bytes / 1024:.1f} КБ")
            self.log(f"Время: {elapsed:.2f}с")
            self.log(f"Средняя скорость: {speed:.1f} КБ/с")
            self.log("Можете открыть папку через кнопку 'Открыть downloaded'")
            
        except Exception as e:
            self.log(f"\n✗ Ошибка: {str(e)}")
            messagebox.showerror("Ошибка", str(e))
            
        finally:
            self.is_downloading = False
            self.root.after(0, self.enable_buttons)
            
    def enable_buttons(self):
        self.download_btn.config(state='normal')
        self.open_btn.config(state='normal')
        self.progress.stop()
        
    def open_downloaded(self):
        try:
            if sys.platform == 'win32':
                os.startfile(self.downloaded_dir)
            elif sys.platform == 'darwin':
                os.system(f'open "{self.downloaded_dir}"')
            else:
                os.system(f'xdg-open "{self.downloaded_dir}"')
        except Exception as e:
            messagebox.showerror("Ошибка", f"Не удалось открыть папку: {str(e)}")
            
    def after(self, ms, func, *args):
        return self.root.after(ms, func, *args)
def main():
    root = tk.Tk()
    app = GitHubDownloader(root)
    root.mainloop()
if __name__ == "__main__":
    main()