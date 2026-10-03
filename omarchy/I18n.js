// Omarchy UI message catalog. Chrome and formatter copy live here; report
// metric labels from Rust stay English at the wire and are remapped only for
// display via displayLabel(). Locale "auto" follows Qt.locale() / $LANG.

var DEFAULT_LOCALE = "en"
var SUPPORTED = ["en", "ru", "pt-BR"]

var MONTHS = {
  en: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
  ru: ["янв", "фев", "мар", "апр", "мая", "июн", "июл", "авг", "сен", "окт", "ноя", "дек"],
  "pt-BR": ["jan", "fev", "mar", "abr", "mai", "jun", "jul", "ago", "set", "out", "nov", "dez"]
}

var LABELS = {
  en: {
    "Cursor Models": "Cursor Models",
    "Other Models": "Other Models",
    "On-Demand": "On-Demand",
    "Cursor Other Models": "Cursor Other Models",
    "Cursor On Demand": "Cursor On Demand",
    "Resets": "Resets",
    "Auto + Composer": "Auto + Composer"
  },
  ru: {
    "Cursor Models": "Модели Cursor",
    "Other Models": "Другие модели",
    "On-Demand": "По запросу",
    "Cursor Other Models": "Другие модели Cursor",
    "Cursor On Demand": "Cursor по запросу",
    "Resets": "Сброс",
    "Auto + Composer": "Auto + Composer"
  },
  "pt-BR": {
    "Cursor Models": "Modelos Cursor",
    "Other Models": "Outros modelos",
    "On-Demand": "Sob demanda",
    "Cursor Other Models": "Outros modelos Cursor",
    "Cursor On Demand": "Cursor sob demanda",
    "Resets": "Redefinições",
    "Auto + Composer": "Auto + Composer"
  }
}

// English wire credential notes remapped for display only.
var NOTE_KEYS = {
  "admin key — monthly spend": "credentials.note.admin_spend",
  "billing balance and monthly spend": "credentials.note.billing_spend",
  "coding-plan usage": "credentials.note.coding_plan",
  "account balance": "credentials.note.account_balance",
  "management key, not the inference key": "credentials.note.management_key",
  "Token Plan subscription key": "credentials.note.token_plan",
  "usage quota": "credentials.note.usage_quota",
  "credit balance": "credentials.note.credit_balance"
}

var MESSAGES = {
  en: {
    "app.name": "AI usage",
    "hero.settings": "Settings",
    "hero.settings_meta": "Display, provider & API keys",
    "hero.settings_detail": "Existing configuration stays in place until you save.",
    "hero.usage_limits": "Usage and limits",
    "hero.loading": "Loading providers",
    "hero.usage_report": "Usage report",
    "hero.provider_unavailable": "Provider unavailable",
    "action.refresh": "Refresh usage",
    "action.settings": "Settings",
    "action.back": "Back to usage",
    "action.retry": "Retry",
    "action.terminal_settings": "Open terminal settings",
    "action.save": "Save settings",
    "action.saving": "Saving…",
    "section.usage": "USAGE",
    "section.usage_balance": "USAGE & BALANCE",
    "section.settings": "SETTINGS",
    "section.display": "DISPLAY",
    "section.bar_window": "TOP BAR WINDOW",
    "section.language": "LANGUAGE",
    "section.primary": "PRIMARY PROVIDER",
    "section.providers": "PROVIDERS",
    "section.auth": "AUTHENTICATION",
    "section.credentials": "CREDENTIALS",
    "loading.config": "Loading configuration…",
    "loading.providers": "Collecting configured providers…",
    "empty.no_usage": "No configured provider reported usage.",
    "status.cached": "Cached data · the provider could not supply a fresh response.",
    "status.refresh_failed": "Refresh failed; showing the previous report. {error}",
    "status.filter_miss": "No configured entry matches ‘{id}’. Clear the provider setting or use an id from ai-usagebar usage --json.",
    "status.saved": "Settings saved. Usage is refreshing.",
    "status.nous_login": "Nous Research login is opening in a terminal.",
    "status.copilot_login": "GitHub sign-in is opening in a terminal. Complete it, then choose GitHub Copilot as primary and save.",
    "status.vendor_on": "On — included in the report.",
    "status.vendor_off": "Off — not fetched.",
    "status.will_clear": "will clear",
    "status.env_set": "set in the environment",
    "status.inline_set": "stored inline",
    "status.not_set": "not set",
    "toggle.show_value": "Show usage value in the top bar",
    "toggle.show_value_desc": "Turn this off for an icon-only bar entry. The panel and tooltip still show full usage details. Applies immediately.",
    "toggle.show_provider": "Show provider name in the top bar",
    "toggle.show_provider_desc": "Turn this on to prefix the bar entry with the provider's short code — cld, gpt, zai, agy — the way Waybar's {vendor_short} does. Off by default. Applies immediately.",
    "toggle.show_all": "Show all providers in the top bar",
    "toggle.show_all_desc": "Turn this on to show every configured provider's icon and usage in the top bar at once, instead of cycling one at a time. Click still opens the panel; the wheel still selects which details you see. Off by default. Applies immediately.",
    "toggle.color_code": "Color-code usage by level",
    "toggle.color_code_desc": "Paint bar values, panel meters, and the tooltip green → yellow → orange → red as usage climbs, using your Omarchy theme. Turn off for a single foreground color everywhere. Off by default. Applies immediately.",
    "bar_window.help": "Which quota the bar shows. Providers lacking it fall back to highest. Applies immediately.",
    "bar_window.auto": "Highest (auto)",
    "bar_window.session": "5-hour (session)",
    "bar_window.weekly": "7-day (weekly)",
    "bar_window.monthly": "Monthly (monthly)",
    "language.help": "Language for the panel and settings. Auto matches your system language.",
    "language.auto": "System (auto)",
    "language.en": "English",
    "language.ru": "Русский",
    "language.pt-BR": "Português (Brasil)",
    "primary.help": "Used by the CLI, Waybar, TUI, and as this panel's preferred provider.",
    "providers.help": "Which providers are fetched at all. Turn one off and it leaves the bar, panel and reports until you switch it back on; turning one on takes effect on the next refresh. Saving a credential for a provider keeps switching it on.",
    "auth.help": "OAuth login opens in a terminal. Complete it, then return here, choose the provider as primary, save, and press Refresh.",
    "auth.nous": "Log in with Nous Research",
    "auth.copilot": "Log in with GitHub Copilot",
    "credentials.help": "Stored values are never loaded into the shell. Leave a field blank to keep its current value, or use the clear button to remove an inline credential. Environment variables take precedence.",
    "credentials.keep_blank": "Leave blank to keep current credential",
    "credentials.paste": "Paste {label}",
    "credentials.keep_key": "Keep the stored key",
    "credentials.clear_key": "Clear the stored inline key",
    "credentials.credential": "credential",
    "credentials.new_key": "new key",
    "credentials.env_override": "environment override",
    "credentials.stored": "stored",
    "credentials.not_configured": "not configured",
    "detail.auto_composer": "Auto + Composer",
    "detail.named_api_on": "Named / API models · on-demand on",
    "detail.named_api_off": "Named / API models · on-demand off",
    "detail.used_of": "{used} of {limit} used ({percent}%)",
    "detail.on_demand_used_of": "On-demand {used} of {limit} used ({percent}%)",
    "credentials.api_key": "API key",
    "credentials.note.admin_spend": "admin key — monthly spend",
    "credentials.note.billing_spend": "billing balance and monthly spend",
    "credentials.note.coding_plan": "coding-plan usage",
    "credentials.note.account_balance": "account balance",
    "credentials.note.management_key": "management key, not the inference key",
    "credentials.note.token_plan": "Token Plan subscription key",
    "credentials.note.usage_quota": "usage quota",
    "credentials.note.credit_balance": "credit balance",
    "error.binary_old": "This installed ai-usagebar binary predates native settings. Update the package, or use the terminal settings fallback.",
    "error.apply": "The settings command did not confirm the save.",
    "pool.models": "Cursor Models",
    "pool.other": "Other Models",
    "pool.demand": "On-Demand",
    "tip.pool_models": "Cursor Models · {percent}%",
    "tip.pool_other": "Cursor Other Models · {percent}%",
    "tip.pool_demand": "Cursor On Demand · {percent}%",
    "tip.cached": "cached",
    "ready": "Ready",
    "error": "Error",
    "reset.due": "Reset due",
    "reset.in": "Resets in {duration} · {clock}",
    "updated.unavailable": "Updated time unavailable",
    "updated.just_now": "Updated just now",
    "updated.ago": "Updated {duration} ago",
    "duration.now": "now",
    "duration.days_hours": "{days}d {hours}h",
    "duration.hours_minutes": "{hours}h {minutes}m",
    "duration.minutes": "{minutes}m"
  },
  ru: {
    "app.name": "AI usage",
    "hero.settings": "Настройки",
    "hero.settings_meta": "Отображение, провайдер и ключи",
    "hero.settings_detail": "Пока вы не нажмёте «Сохранить», ничего не изменится.",
    "hero.usage_limits": "Использование и лимиты",
    "hero.loading": "Загрузка провайдеров",
    "hero.usage_report": "Отчёт об использовании",
    "hero.provider_unavailable": "Провайдер недоступен",
    "action.refresh": "Обновить данные",
    "action.settings": "Настройки",
    "action.back": "Назад к использованию",
    "action.retry": "Повторить",
    "action.terminal_settings": "Открыть настройки в терминале",
    "action.save": "Сохранить",
    "action.saving": "Сохранение…",
    "section.usage": "ИСПОЛЬЗОВАНИЕ",
    "section.usage_balance": "ИСПОЛЬЗОВАНИЕ И БАЛАНС",
    "section.settings": "НАСТРОЙКИ",
    "section.display": "ОТОБРАЖЕНИЕ",
    "section.bar_window": "ОКНО НА ПАНЕЛИ",
    "section.language": "ЯЗЫК",
    "section.primary": "ОСНОВНОЙ ПРОВАЙДЕР",
    "section.providers": "ПРОВАЙДЕРЫ",
    "section.auth": "АВТОРИЗАЦИЯ",
    "section.credentials": "УЧЁТНЫЕ ДАННЫЕ",
    "loading.config": "Загрузка конфигурации…",
    "loading.providers": "Опрос настроенных провайдеров…",
    "empty.no_usage": "Ни один настроенный провайдер не вернул данные.",
    "status.cached": "Кэш · провайдер не смог отдать свежий ответ.",
    "status.refresh_failed": "Обновление не удалось; показан прошлый отчёт. {error}",
    "status.filter_miss": "Нет записи «{id}». Сбросьте провайдер в настройках или укажите id из ai-usagebar usage --json.",
    "status.saved": "Настройки сохранены. Данные обновляются.",
    "status.nous_login": "Вход Nous Research открывается в терминале.",
    "status.copilot_login": "Вход GitHub открывается в терминале. Завершите его, выберите GitHub Copilot основным провайдером и сохраните.",
    "status.vendor_on": "Вкл. — участвует в отчёте.",
    "status.vendor_off": "Выкл. — не опрашивается.",
    "status.will_clear": "будет удалено",
    "status.env_set": "задано в окружении",
    "status.inline_set": "сохранено в конфиге",
    "status.not_set": "не задано",
    "toggle.show_value": "Показывать значение на панели",
    "toggle.show_value_desc": "Выключите, чтобы оставить только иконку. Панель и подсказка по-прежнему показывают полные данные. Применяется сразу.",
    "toggle.show_provider": "Показывать имя провайдера на панели",
    "toggle.show_provider_desc": "Добавляет короткий код провайдера — cld, gpt, zai, agy — как {vendor_short} в Waybar. По умолчанию выкл. Применяется сразу.",
    "toggle.show_all": "Показывать всех провайдеров на панели",
    "toggle.show_all_desc": "Показывает иконки и usage всех настроенных провайдеров сразу, без переключения по одному. Клик открывает панель; колёсико выбирает детали. По умолчанию выкл. Применяется сразу.",
    "toggle.color_code": "Раскрашивать usage по уровню",
    "toggle.color_code_desc": "Красит значения на панели, полоски в панели и подсказку зелёный → жёлтый → оранжевый → красный по заполнению квоты (цвета темы Omarchy). Выключите для одного цвета интерфейса. По умолчанию выкл. Применяется сразу.",
    "bar_window.help": "Какую квоту показывает панель. Если окна нет — берётся наибольшая. Применяется сразу.",
    "bar_window.auto": "Наибольшая (auto)",
    "bar_window.session": "5 часов (session)",
    "bar_window.weekly": "7 дней (weekly)",
    "bar_window.monthly": "Месяц (monthly)",
    "language.help": "Язык панели и настроек. «Авто» совпадает с языком системы.",
    "language.auto": "Системный (авто)",
    "language.en": "English",
    "language.ru": "Русский",
    "language.pt-BR": "Português (Brasil)",
    "primary.help": "Используется CLI, Waybar, TUI и как предпочтительный провайдер этой панели.",
    "providers.help": "Какие провайдеры вообще опрашиваются. Выключенный пропадает из трея, панели и отчётов, пока не включите снова; включение действует со следующего обновления. Сохранение ключа само включает провайдера.",
    "auth.help": "OAuth открывается в терминале. Завершите вход, вернитесь сюда, выберите провайдера основным, сохраните и нажмите «Обновить».",
    "auth.nous": "Войти через Nous Research",
    "auth.copilot": "Войти через GitHub Copilot",
    "credentials.help": "Значения ключей в shell не загружаются. Оставьте поле пустым, чтобы сохранить текущее, или очистите кнопкой. Переменные окружения имеют приоритет.",
    "credentials.keep_blank": "Оставьте пустым, чтобы сохранить текущий ключ",
    "credentials.paste": "Вставьте {label}",
    "credentials.keep_key": "Оставить сохранённый ключ",
    "credentials.clear_key": "Удалить ключ из конфига",
    "credentials.credential": "ключ",
    "credentials.new_key": "новый ключ",
    "credentials.env_override": "переопределение из окружения",
    "credentials.stored": "сохранено",
    "credentials.not_configured": "не настроено",
    "detail.auto_composer": "Auto + Composer",
    "detail.named_api_on": "Именованные / API-модели · on-demand вкл.",
    "detail.named_api_off": "Именованные / API-модели · on-demand выкл.",
    "detail.used_of": "{used} из {limit} использовано ({percent}%)",
    "detail.on_demand_used_of": "По запросу: {used} из {limit} ({percent}%)",
    "credentials.api_key": "API-ключ",
    "credentials.note.admin_spend": "admin-ключ — месячные траты",
    "credentials.note.billing_spend": "баланс и месячные траты",
    "credentials.note.coding_plan": "usage coding-plan",
    "credentials.note.account_balance": "баланс аккаунта",
    "credentials.note.management_key": "management-ключ, не inference",
    "credentials.note.token_plan": "ключ подписки Token Plan",
    "credentials.note.usage_quota": "квота использования",
    "credentials.note.credit_balance": "кредитный баланс",
    "error.binary_old": "Установленный ai-usagebar слишком старый для нативных настроек. Обновите пакет или откройте настройки в терминале.",
    "error.apply": "Команда настроек не подтвердила сохранение.",
    "pool.models": "Модели Cursor",
    "pool.other": "Другие модели",
    "pool.demand": "По запросу",
    "tip.pool_models": "Модели Cursor · {percent}%",
    "tip.pool_other": "Другие модели Cursor · {percent}%",
    "tip.pool_demand": "Cursor по запросу · {percent}%",
    "tip.cached": "кэш",
    "ready": "Готово",
    "error": "Ошибка",
    "reset.due": "Пора сбросить",
    "reset.in": "Сброс через {duration} · {clock}",
    "updated.unavailable": "Время обновления недоступно",
    "updated.just_now": "Обновлено только что",
    "updated.ago": "Обновлено {duration} назад",
    "duration.now": "сейчас",
    "duration.days_hours": "{days}д {hours}ч",
    "duration.hours_minutes": "{hours}ч {minutes}м",
    "duration.minutes": "{minutes}м"
  },
  "pt-BR": {
    "app.name": "AI usage",
    "hero.settings": "Configurações",
    "hero.settings_meta": "Exibição, provedor e chaves de API",
    "hero.settings_detail": "A configuração atual permanece até você salvar.",
    "hero.usage_limits": "Uso e limites",
    "hero.loading": "Carregando provedores",
    "hero.usage_report": "Relatório de uso",
    "hero.provider_unavailable": "Provedor indisponível",
    "action.refresh": "Atualizar uso",
    "action.settings": "Configurações",
    "action.back": "Voltar ao uso",
    "action.retry": "Tentar novamente",
    "action.terminal_settings": "Abrir configurações no terminal",
    "action.save": "Salvar configurações",
    "action.saving": "Salvando…",
    "section.usage": "USO",
    "section.usage_balance": "USO E SALDO",
    "section.settings": "CONFIGURAÇÕES",
    "section.display": "EXIBIÇÃO",
    "section.bar_window": "JANELA NA BARRA",
    "section.language": "IDIOMA",
    "section.primary": "PROVEDOR PRINCIPAL",
    "section.providers": "PROVEDORES",
    "section.auth": "AUTENTICAÇÃO",
    "section.credentials": "CREDENCIAIS",
    "loading.config": "Carregando configuração…",
    "loading.providers": "Coletando provedores configurados…",
    "empty.no_usage": "Nenhum provedor configurado informou uso.",
    "status.cached": "Dados em cache · o provedor não enviou uma resposta nova.",
    "status.refresh_failed": "Falha na atualização; mostrando o relatório anterior. {error}",
    "status.filter_miss": "Nenhuma entrada configurada corresponde a ‘{id}’. Limpe o provedor nas configurações ou use um id de ai-usagebar usage --json.",
    "status.saved": "Configurações salvas. Atualizando o uso.",
    "status.nous_login": "O login da Nous Research está abrindo no terminal.",
    "status.copilot_login": "O login do GitHub está abrindo no terminal. Conclua, escolha GitHub Copilot como principal e salve.",
    "status.vendor_on": "Ativado — incluído no relatório.",
    "status.vendor_off": "Desativado — não consultado.",
    "status.will_clear": "será removido",
    "status.env_set": "definido no ambiente",
    "status.inline_set": "salvo no config",
    "status.not_set": "não definido",
    "toggle.show_value": "Mostrar valor de uso na barra",
    "toggle.show_value_desc": "Desative para deixar só o ícone. O painel e a dica ainda mostram os detalhes. Aplica imediatamente.",
    "toggle.show_provider": "Mostrar nome do provedor na barra",
    "toggle.show_provider_desc": "Prefixa a entrada da barra com o código curto do provedor — cld, gpt, zai, agy — como {vendor_short} no Waybar. Desativado por padrão. Aplica imediatamente.",
    "toggle.show_all": "Mostrar todos os provedores na barra",
    "toggle.show_all_desc": "Mostra ícone e uso de todos os provedores configurados de uma vez, em vez de alternar um por um. O clique ainda abre o painel; a roda ainda escolhe os detalhes. Desativado por padrão. Aplica imediatamente.",
    "toggle.color_code": "Colorir uso por nível",
    "toggle.color_code_desc": "Pinta valores da barra, medidores do painel e a dica de verde → amarelo → laranja → vermelho conforme o uso sobe, com as cores do tema Omarchy. Desative para uma só cor de texto. Desativado por padrão. Aplica imediatamente.",
    "bar_window.help": "Qual cota a barra mostra. Sem essa janela, usa a maior. Aplica imediatamente.",
    "bar_window.auto": "Maior uso (auto)",
    "bar_window.session": "5 horas (session)",
    "bar_window.weekly": "7 dias (weekly)",
    "bar_window.monthly": "Mensal (monthly)",
    "language.help": "Idioma do painel e das configurações. Automático segue o idioma do sistema.",
    "language.auto": "Sistema (auto)",
    "language.en": "English",
    "language.ru": "Русский",
    "language.pt-BR": "Português (Brasil)",
    "primary.help": "Usado pelo CLI, Waybar, TUI e como provedor preferido deste painel.",
    "providers.help": "Quais provedores são consultados. Desligar remove da barra, do painel e dos relatórios até ligar de novo; ligar vale na próxima atualização. Salvar uma credencial mantém o provedor ligado.",
    "auth.help": "O login OAuth abre no terminal. Conclua, volte aqui, escolha o provedor como principal, salve e pressione Atualizar.",
    "auth.nous": "Entrar com Nous Research",
    "auth.copilot": "Entrar com GitHub Copilot",
    "credentials.help": "Valores salvos nunca são carregados no shell. Deixe em branco para manter o atual, ou use limpar para remover a credencial inline. Variáveis de ambiente têm prioridade.",
    "credentials.keep_blank": "Deixe em branco para manter a credencial atual",
    "credentials.paste": "Cole {label}",
    "credentials.keep_key": "Manter a chave salva",
    "credentials.clear_key": "Limpar a chave salva no config",
    "credentials.credential": "credencial",
    "credentials.new_key": "nova chave",
    "credentials.env_override": "sobrescrita do ambiente",
    "credentials.stored": "salvo",
    "credentials.not_configured": "não configurado",
    "detail.auto_composer": "Auto + Composer",
    "detail.named_api_on": "Modelos nomeados / API · on-demand ligado",
    "detail.named_api_off": "Modelos nomeados / API · on-demand desligado",
    "detail.used_of": "{used} de {limit} usados ({percent}%)",
    "detail.on_demand_used_of": "Sob demanda: {used} de {limit} ({percent}%)",
    "credentials.api_key": "Chave de API",
    "credentials.note.admin_spend": "chave admin — gasto mensal",
    "credentials.note.billing_spend": "saldo e gasto mensal",
    "credentials.note.coding_plan": "uso do coding-plan",
    "credentials.note.account_balance": "saldo da conta",
    "credentials.note.management_key": "chave de gerenciamento, não a de inferência",
    "credentials.note.token_plan": "chave da assinatura Token Plan",
    "credentials.note.usage_quota": "cota de uso",
    "credentials.note.credit_balance": "saldo de créditos",
    "error.binary_old": "O binário ai-usagebar instalado é anterior às configurações nativas. Atualize o pacote ou use as configurações no terminal.",
    "error.apply": "O comando de configurações não confirmou o salvamento.",
    "pool.models": "Modelos Cursor",
    "pool.other": "Outros modelos",
    "pool.demand": "Sob demanda",
    "tip.pool_models": "Modelos Cursor · {percent}%",
    "tip.pool_other": "Outros modelos Cursor · {percent}%",
    "tip.pool_demand": "Cursor sob demanda · {percent}%",
    "tip.cached": "em cache",
    "ready": "Pronto",
    "error": "Erro",
    "reset.due": "Redefinição devida",
    "reset.in": "Redefine em {duration} · {clock}",
    "updated.unavailable": "Horário de atualização indisponível",
    "updated.just_now": "Atualizado agora",
    "updated.ago": "Atualizado há {duration}",
    "duration.now": "agora",
    "duration.days_hours": "{days}d {hours}h",
    "duration.hours_minutes": "{hours}h {minutes}m",
    "duration.minutes": "{minutes}m"
  }
}

function normalizeLocaleTag(value) {
  var text = String(value === undefined || value === null ? "" : value).trim().toLowerCase()
  if (text === "auto" || text === "") return "auto"
  if (text.indexOf("pt") === 0) return "pt-BR"
  if (text.indexOf("ru") === 0) return "ru"
  if (text.indexOf("en") === 0) return "en"
  var dash = text.indexOf("-")
  var under = text.indexOf("_")
  var cut = dash >= 0 ? dash : under
  var base = cut >= 0 ? text.slice(0, cut) : text
  if (SUPPORTED.indexOf(base) >= 0) return base
  return ""
}

function resolveLocale(setting, systemName) {
  var chosen = normalizeLocaleTag(setting)
  if (chosen && chosen !== "auto") return chosen
  var system = normalizeLocaleTag(systemName)
  if (system && system !== "auto") return system
  return DEFAULT_LOCALE
}

function catalog(locale) {
  var tag = resolveLocale(locale, "")
  return MESSAGES[tag] || MESSAGES[DEFAULT_LOCALE]
}

function t(locale, key, params) {
  var table = catalog(locale)
  var fallback = MESSAGES[DEFAULT_LOCALE]
  var template = table[key]
  if (template === undefined || template === null) template = fallback[key]
  if (template === undefined || template === null) return String(key || "")
  var out = String(template)
  var values = params && typeof params === "object" ? params : {}
  for (var name in values) {
    if (!Object.prototype.hasOwnProperty.call(values, name)) continue
    out = out.split("{" + name + "}").join(String(values[name]))
  }
  return out
}

function displayLabel(locale, label) {
  var text = String(label || "")
  if (text === "") return ""
  var tag = resolveLocale(locale, "")
  var table = LABELS[tag] || LABELS[DEFAULT_LOCALE]
  if (table[text] !== undefined) return table[text]
  return text
}

function displayDetail(locale, detail) {
  var text = String(detail || "").trim()
  if (text === "") return ""
  if (text === "Auto + Composer") return t(locale, "detail.auto_composer")
  var named = text.match(/^Named \/ API models · on-demand (on|off)$/i)
  if (named)
    return t(locale, named[1].toLowerCase() === "on" ? "detail.named_api_on" : "detail.named_api_off")
  var used = text.match(/^(.+?) of (.+?) used \((\d+)%\)$/)
  if (used)
    return t(locale, "detail.used_of", { used: used[1], limit: used[2], percent: used[3] })
  var demand = text.match(/^On-demand (.+?) of (.+?) used \((\d+)%\)$/i)
  if (demand)
    return t(locale, "detail.on_demand_used_of", {
      used: demand[1], limit: demand[2], percent: demand[3]
    })
  var labeled = displayLabel(locale, text)
  if (labeled !== text) return labeled
  return text
}

function displaySecretLabel(locale, label) {
  var text = String(label || "").trim()
  if (text === "API key") return t(locale, "credentials.api_key")
  return text
}

function displayNote(locale, note) {
  var text = String(note || "").trim()
  if (text === "") return ""
  var key = NOTE_KEYS[text]
  if (key) return t(locale, key)
  return text
}

function monthName(locale, monthIndex) {
  var tag = resolveLocale(locale, "")
  var list = MONTHS[tag] || MONTHS[DEFAULT_LOCALE]
  var idx = Number(monthIndex)
  if (!(idx >= 0 && idx < list.length)) return ""
  return list[idx]
}

function formatDuration(milliseconds, locale) {
  if (!(milliseconds > 0)) return t(locale, "duration.now")
  var minutes = Math.floor(milliseconds / 60000)
  var hours = Math.floor(minutes / 60)
  var days = Math.floor(hours / 24)
  if (days > 0)
    return t(locale, "duration.days_hours", { days: days, hours: hours % 24 })
  if (hours > 0)
    return t(locale, "duration.hours_minutes", { hours: hours, minutes: minutes % 60 })
  return t(locale, "duration.minutes", { minutes: Math.max(1, minutes) })
}

function tipPoolLine(locale, poolId, percent) {
  var key = poolId === "other" ? "tip.pool_other"
    : poolId === "demand" ? "tip.pool_demand"
    : "tip.pool_models"
  return t(locale, key, { percent: percent })
}

function pad2(value) {
  return ("0" + value).slice(-2)
}

function isSameLocalDay(a, b) {
  return a.getFullYear() === b.getFullYear()
    && a.getMonth() === b.getMonth()
    && a.getDate() === b.getDate()
}

// Locale-aware copies of Model.formatReset / formatUpdated for panel display.
function formatReset(resetAt, nowMs, locale) {
  if (!resetAt) return ""
  var resetMs = new Date(String(resetAt)).getTime()
  if (!isFinite(resetMs)) return ""
  var remaining = resetMs - Number(nowMs)
  if (remaining <= 0) return t(locale, "reset.due")
  var at = new Date(resetMs)
  var clock = pad2(at.getHours()) + ":" + pad2(at.getMinutes())
  if (!isSameLocalDay(at, new Date(Number(nowMs))))
    clock = monthName(locale, at.getMonth()) + " " + at.getDate() + " " + clock
  return t(locale, "reset.in", {
    duration: formatDuration(remaining, locale),
    clock: clock
  })
}

function formatUpdated(fetchedAt, nowMs, locale) {
  if (!fetchedAt) return t(locale, "updated.unavailable")
  var fetchedMs = new Date(String(fetchedAt)).getTime()
  if (!isFinite(fetchedMs)) return t(locale, "updated.unavailable")
  var elapsed = Math.max(0, Number(nowMs) - fetchedMs)
  if (elapsed < 60000) return t(locale, "updated.just_now")
  return t(locale, "updated.ago", { duration: formatDuration(elapsed, locale) })
}
