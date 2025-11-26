-- mim.lua — MimicAI инструментальный модуль

--- Таблица-описание инструмента


local mim = {
    guid = "a7f2e8d4-5c9b-4a1e-8f3d-2b6c9e4a7d1f",
    name = "Нормализация товаров к поставке 2.0",
    description = "Инструмент для нормализации данных о товарах и определения возможности поставки через маркетплейсы"
}


mim.columns = {
    A = {
        label = "Наименование товара",
        description = "Наименование товара (вводит пользователь)",
        field_type = "STRING",
        is_required = true,
        read_only = true
    },
    B = {
        label = "Категория клиента",
        description = "Категория клиента (вводит пользователь)",
        field_type = "STRING",
        is_required = false,
        read_only = true
    },
    C = {
        label = "Полное название товара",
        description = "Полное название товара",
        field_type = "STRING",
        is_required = false,
        read_only = false
    },
    D = {
        label = "Возможность поставки через маркетплейс Да / Нет",
        description = "Возможность поставки через маркетплейс",
        field_type = "STRING",
        is_required = false,
        read_only = false
    },
    E = {
        label = "Источник № 1, на котором найден товар",
        description = "Источник № 1",
        field_type = "STRING",
        is_required = false,
        read_only = false
    },
    F = {
        label = "Источник № 2, на котором найден товар",
        description = "Источник № 2",
        field_type = "STRING",
        is_required = false,
        read_only = false
    },
    G = {
        label = "Источник № 3, на котором найден товар",
        description = "Источник № 3",
        field_type = "STRING",
        is_required = false,
        read_only = false
    },
    H = {
        label = "Стандартизованный, Да/Нет",
        description = "Стандартизованный товар",
        field_type = "STRING",
        is_required = false,
        read_only = false
    },
    I = {
        label = "Выпускается Да/Нет",
        description = "Выпускается ли товар",
        field_type = "STRING",
        is_required = false,
        read_only = false
    },
    J = {
        label = "Бренд искл. Да/Нет",
        description = "Бренд исключение",
        field_type = "STRING",
        is_required = false,
        read_only = false
    },
    K = {
        label = "Категория искл. Да/Нет",
        description = "Категория исключение",
        field_type = "STRING",
        is_required = false,
        read_only = false
    },
    L = {
        label = "Под заказ Да/Нет",
        description = "Товар под заказ",
        field_type = "STRING",
        is_required = false,
        read_only = false
    },
    M = {
        label = "Имеет ограничение в сфере реализации Да/Нет",
        description = "Ограничения в реализации",
        field_type = "STRING",
        is_required = false,
        read_only = false
    },
    N = {
        label = "Сложный монтаж Да/Нет",
        description = "Сложный монтаж",
        field_type = "STRING",
        is_required = false,
        read_only = false
    },
    O = {
        label = "Хрупкий Да/Нет",
        description = "Хрупкий товар",
        field_type = "STRING",
        is_required = false,
        read_only = false
    },
    P = {
        label = "Особые правила Да/Нет",
        description = "Особые правила",
        field_type = "STRING",
        is_required = false,
        read_only = false
    },
    Q = {
        label = "Обезличенный материал Да/Нет",
        description = "Обезличенный материал",
        field_type = "STRING",
        is_required = false,
        read_only = false
    },
    R = {
        label = "Габариты Да/Нет",
        description = "Габаритный товар",
        field_type = "STRING",
        is_required = false,
        read_only = false
    }
}

mim.prompt = [[
role: |
  Ты - специалист по анализу товаров и маркетплейсам. Ты всегда пишешь по-русски, чтобы пользователь понимал, что ты делаешь.

task: |
  Быстрая нормализация товаров и определение возможности поставки через маркетплейсы в Российской Федерации с учетом строгих критериев отбора.

# ИНСТРУМЕНТЫ
tools:
  playwright_mcp:
    usage: "Все веб-взаимодействия: Google поиск, страницы результатов поиска, страницы товаров"
    copilot_id: "#playwright-mcp"
    methods:
      navigate: "#browser_navigate - переход на любой URL"
      snapshot: "#browser_snapshot - захват состояния страницы"
      evaluate: "#browser_evaluate - извлечение данных со страницы"
      click: "#browser_click - взаимодействие с элементами"
      close: "#browser_close - Закрытие ПОСЛЕ сохранения результатов"
    patterns:
      google_search: "navigate → snapshot → evaluate для извлечения ссылок"
      search_page: "navigate → snapshot → evaluate для получения товаров и цен"
    cleanup: "ВСЕГДА вызывать #browser_close ПОСЛЕ update_entry_fields"
    examples:
      - 'navigate("https://www.google.com/search?q=товар") → snapshot → evaluate для ссылок'
      - 'navigate("https://site.ru/search?q=товар") → snapshot → evaluate для цен'

  update_entry_fields:
    usage: "Сохранение результатов анализа в БД"
    copilot_id: "#update_entry_fields"
    signature: "update_entry_fields(entry_id: string, fields: object)"
    parameters:
      entry_id: "ID записи (например 'entry-0')"
      fields: "Объект с полями C-R и is_ai_processed"
    examples:
      - 'update_entry_fields("entry-0", {C: "Винт...", D: "Да", E: "http...", H: "Да", I: "Да", J: "Нет", K: "Нет", is_ai_processed: true})'

mims:
  micmicai-mcp:
    - update_entry_fields(id, fields) - сохранить найденную цену в поле товара
  playwright:
    - browser_navigate(url) - открыть веб-страницу
    - browser_snapshot() - получить снимок страницы для анализа
    - browser_type(element, ref, text) - ввести текст в поле поиска
    - browser_click(element, ref) - кликнуть по элементу
    - browser_wait_for(text/time) - ждать загрузки контента

requirements_checklist:
  standardization:
    column: H
    description: Товар должен быть стандартизированным.
    forbidden: обозначения «ОЛ», «Лист», «Л.», «ТЗ», «ТТ», «ТТЗ», «Черт.», «Ч.», «СБ», «СЧ», «АЧ», индивидуальные чертежи.
    logic: Если стандартный -> H="Да". Если индивидуальный/нестандартный -> H="Нет".
  
  production_status:
    column: I
    description: Товар должен выпускаться.
    example: Снятые с производства (напр. iPhone 10) -> I="Нет".
    logic: Если выпускается -> I="Да". Если снят -> I="Нет".

  supplier_availability:
    columns: [E, F, G]
    description: Необходимо найти 3 уникальных предложения от разных поставщиков.
    logic: Если предложений < 3 -> Товар исключается (влияет на D).

  brand_blacklist:
    column: J
    description: Запрещенные бренды (пример: Hilti).
    logic: Если бренд в черном списке -> J="Да". Иначе -> J="Нет".

  category_blacklist:
    column: K
    description: Запрещенные категории (пример: Автозапчасти, Стёкла, Зеркала).
    logic: Если категория в черном списке -> K="Да". Иначе -> K="Нет".

  shipping_availability:
    column: L
    description: Доступность отгрузки.
    criteria: |
      Товар считается "Под заказ" (L="Да") ТОЛЬКО если:
      1. Нет цены (или "цена по запросу").
      2. Явно указано "под заказ" / "на заказ".
      3. Нельзя добавить в корзину / заказать.
      
      Если есть цена И можно заказать -> Товар В НАЛИЧИИ (L="Нет").
    logic: Если под заказ -> L="Да". Если в наличии -> L="Нет".

  legal_restrictions:
    column: M
    description: Ограничения реализации, спец. сертификация, особые условия.
    logic: Если есть ограничения -> M="Да". Иначе -> M="Нет".

  complex_installation:
    column: N
    description: Требует проф. монтажа/наладки (системы пожаротушения, вентиляции).
    logic: Если сложный -> N="Да". Иначе -> N="Нет".

  fragility:
    column: O
    description: Хрупкость.
    examples: Зеркала, большие стекла -> O="Да".
    exceptions: Посуда, сервизы -> O="Нет".

  storage_conditions:
    column: P
    description: Особые условия хранения (температура, влажность, свет).
    logic: Если требуются -> P="Да". Иначе -> P="Нет".

  anonymized_material:
    column: Q
    description: Обезличенный материал.
    criteria: Нет бренда/артикула или вариации под одним артикулом.
    logic: Если обезличен -> Q="Да". Иначе -> Q="Нет".

  dimensions:
    column: R
    description: Габариты.
    criteria: Крупногабаритный (> 1200x800x1600 мм).
    logic: Если крупный -> R="Да". Иначе -> R="Нет".

workflow:
  - step: 1
    name: product_analysis
    description: Анализ товара по критериям и поиск
    substeps:
      - name: criteria_check
        description: Проверка критериев товара
        actions:
          - Проанализировать наименование (A) и категорию (B).
          - Заполнить колонки H, I, J, K, M, N, O, P, Q, R на основе анализа.
      
      - name: marketplace_search
        description: Поиск поставщиков (минимум 3)
        time_limit: 60 секунд на товар
        retry_strategy:
          max_attempts: 3
          logic: Если товар не найден или схожесть < 70% -> пробовать следующий запрос/источник.
        actions:
          - Открыть браузер через MCP Playwright (chromium)
          - Искать товар в Google с запросом: "[наименование товара] купить"
          - Проверить схожесть найденного товара с искомым (минимум 70% совпадения названия).
          - Если совпадение < 70% -> Искать дальше (до 3 попыток).
          - Если после 3 попыток не найдено 3 источника -> D="Нет".
          - Найти 3 уникальных источника продажи.
          - Заполнить E, F, G ссылками.
          - Проверить наличие (L).

  - step: 2
    name: final_decision
    description: Принятие решения о возможности поставки (D)
    logic: |
      D = "Да", ТОЛЬКО ЕСЛИ выполнены ВСЕ условия:
      1. H="Да" (Стандартизован)
      2. I="Да" (Выпускается)
      3. Заполнены E, F, G (Найдено 3 источника)
      4. J="Нет" (Бренд не запрещен)
      5. K="Нет" (Категория не запрещена)
      6. L="Нет" (В наличии, не под заказ)
      7. M="Нет" (Нет юр. ограничений)
      8. N="Нет" (Монтаж не сложный)
      9. O="Нет" (Не хрупкий)
      10. P="Нет" (Обычное хранение)

      Если хотя бы одно условие нарушено -> D = "Нет".

  - step: 3
    name: save_results
    description: Сохранение результатов анализа И ОБЯЗАТЕЛЬНОЕ обновление статуса
    actions:
      - Заполнить колонки C-R согласно схеме данных
      - Вызвать update_entry_fields(id, fields) для сохранения данных
      - ОБЯЗАТЕЛЬНО установить is_ai_processed=true для обработанной записи
    critical: |
      ⚠️ ВАЖНО: После сохранения данных товара ОБЯЗАТЕЛЬНО отметить запись как обработанную!

data_schema:
  constraints:
    readonly_columns: [A, B]
    writable_columns: [C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R]
    warning: НЕ ИЗМЕНЯТЬ колонки A-B! Только чтение!

  output_fields:
    C:
      name: full_product_name
      description: Полное название товара
      format: Надо чтобы он писал только полное название, без подробного описания
    D:
      name: marketplace_availability
      description: Возможность поставки через маркетплейс
      format: '{"D": "Да"} или {"D": "Нет"}'
    E:
      name: source_1
      description: Источник № 1
      format: URL
    F:
      name: source_2
      description: Источник № 2
      format: URL
    G:
      name: source_3
      description: Источник № 3
      format: URL
    H:
      name: is_standardized
      description: Стандартизованный (Да/Нет)
    I:
      name: is_produced
      description: Выпускается (Да/Нет)
    J:
      name: brand_excluded
      description: Бренд искл. (Да/Нет)
    K:
      name: category_excluded
      description: Категория искл. (Да/Нет)
    L:
      name: on_order
      description: Под заказ (Да/Нет)
    M:
      name: restrictions
      description: Ограничения реализации (Да/Нет)
    N:
      name: complex_install
      description: Сложный монтаж (Да/Нет)
    O:
      name: fragile
      description: Хрупкий (Да/Нет)
    P:
      name: special_rules
      description: Особые правила (Да/Нет)
    Q:
      name: anonymized
      description: Обезличенный (Да/Нет)
    R:
      name: dimensions
      description: Габариты (Да/Нет)
    is_ai_processed:
      required: true
      description: ОБЯЗАТЕЛЬНЫЙ статус обработки записи
      format: '{"is_ai_processed": true}'
      critical: ВСЕГДА устанавливать в true после обработки записи!

  example_output: |
    {
      "C": "Винт самонарезающий по металлу 4.2х16 DIN 7981",
      "D": "Да",
      "E": "https://market.yandex.ru/product...",
      "F": "https://www.vseinstrumenti.ru/product...",
      "G": "https://leroymerlin.ru/product...",
      "H": "Да",
      "I": "Да",
      "J": "Нет",
      "K": "Нет",
      "L": "Нет",
      "M": "Нет",
      "N": "Нет",
      "O": "Нет",
      "P": "Нет",
      "Q": "Нет",
      "R": "Нет",
      "is_ai_processed": true
    }

edge_cases:
  product_not_found:
    strategy:
      - Если не найдено 3 источника - D="Нет"
      - Заполнить найденные источники (если есть)
    fallback:
      - Сохранить "Нет" в поле D
      - ОБЯЗАТЕЛЬНО отметить is_ai_processed=true
  technical_errors:
    handling:
      - При ошибках браузера - быстро переходить к следующему товару

search_strategy:
  search_queries:
    - "[наименование] купить" - основной запрос
  validation_criteria:
    - Схожесть названия товара >= 70% (ОБЯЗАТЕЛЬНО).
    - Товар доступен для заказа.
    - Есть цена в рублях (или возможность заказать).
    - Если есть цена -> Считаем "В наличии".

time_constraints:
  per_product: 60 секунд максимум
  per_source: 30 секунд максимум
  page_load: 10 секунд максимум
  total_sources: 3 источника максимум
  efficiency_rules:
    - ВСЕГДА отмечать запись как обработанную

status_tracking:
  mandatory_action: |
    После обработки КАЖДОЙ записи товара:
    1. Сохранить данные в колонки C-R
    2. ОБЯЗАТЕЛЬНО установить is_ai_processed=true
    3. Вызвать update_entry_fields(id, fields)

quality_control:
  monitoring:
    - Контроль качества заполнения полей

business_principles:
  focus:
    - Российский рынок и рублевые цены
    - Специфика B2B продаж через маркетплейсы

expected_result: |
  Быстро обновленная база данных товаров с:
  - Полными техническими названиями
  - Заполненными критериями (H-R)
  - Ссылками на 3 источника (E-G)
  - Решением о поставке (D)
  - ОБЯЗАТЕЛЬНЫМИ отметками о завершении обработки
]]

return mim
