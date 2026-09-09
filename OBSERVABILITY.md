# Observability Stack — Памятка

## Общая картина.

```
Приложения / Docker контейнеры
          ↓
        Alloy          ← агент сбора, единая точка входа
       /  |  \
      ↓   ↓   ↓
    Loki Tempo Prometheus   ← специализированные хранилища
      \   |   /
        Grafana        ← единый UI для просмотра всего
```

---

## Компоненты

### Alloy — агент / pipeline
**Что делает:** собирает логи, трейсы, метрики и роутит в нужные хранилища.
**Аналогия:** почтовый сортировочный центр — принимает всё, отправляет куда надо.

```
Docker логи → Alloy → Loki
Spring трейсы (OTLP :4317) → Alloy → Tempo
```

---

### Loki — хранилище логов
**Что делает:** хранит текстовые логи с labels для фильтрации.
**Аналогия:** журнал событий с поиском по меткам.
**Протокол:** Push (Alloy толкает логи в Loki)

```
"2024-01-01 ERROR NullPointerException in UserService"
  container=person-api, stream=stderr, job=docker
```

**Запрос в Grafana (LogQL):**
```
{container="person-api"} |= "ERROR"
```

---

### Tempo — хранилище трейсов
**Что делает:** хранит распределённые трейсы — путь запроса через все сервисы.
**Аналогия:** GPS трекер запроса от клиента до БД.

```
Request → API (50ms) → Person Service (30ms) → PostgreSQL (10ms)
           span1           span2                    span3
           └──────────── trace_id: abc123 ─────────────┘
```

---

### Prometheus — хранилище метрик
**Что делает:** собирает числовые метрики через scrape (сам приходит и забирает).
**Аналогия:** счётчик который регулярно снимает показания.
**Протокол:** Pull (Prometheus сам опрашивает /metrics каждые 10s)

```
http_requests_total{method="GET", status="200"} 1234
jvm_memory_used_bytes 512000000
db_connections_active 5
```

**Spring Boot:** `/actuator/prometheus` — endpoint с метриками
**postgres-exporter:** PostgreSQL не умеет отдавать метрики сам → exporter делает за него

**Запрос в Grafana (PromQL):**
```
rate(http_requests_total[5m])
```

---

### Grafana — UI для всего
**Что делает:** единый интерфейс для просмотра логов (Loki), трейсов (Tempo) и метрик (Prometheus).
**Аналогия:** дашборд автомобиля — все показатели в одном месте.

```
Datasources:
  Prometheus → http://prometheus:9090
  Loki       → http://loki:3100
  Tempo      → http://tempo:3200
```

---

### Keycloak — Identity Provider (IAM)
**Что делает:** аутентификация, авторизация, выдача JWT токенов.
**Аналогия:** охранник на входе — проверяет кто ты и что тебе можно.

```
Клиент → Keycloak (логин) → JWT токен
Клиент → Сервис (с JWT) → сервис проверяет подпись → доступ разрешён
```

---

### Nexus — Maven репозиторий
**Что делает:** хранит артефакты (JAR файлы), в том числе сгенерированные SDK.
**Аналогия:** внутренний Maven Central только для твоих библиотек.

```
person-service → OpenAPI codegen → person-api-sdk.jar → Nexus
api-service → зависимость person-api-sdk → скачивает из Nexus
```

---

## Типы данных

| Тип | Хранилище | Протокол | Пример |
|-----|-----------|----------|--------|
| Логи | Loki | Push | `ERROR: Connection refused` |
| Трейсы | Tempo | Push (OTLP) | запрос прошёл через 3 сервиса за 90ms |
| Метрики | Prometheus | Pull (scrape) | CPU 80%, latency p99 = 200ms |

---

## Pull vs Push

```
Pull (Prometheus):
  Prometheus → "дай метрики" → Сервис отвечает
  + просто для сервиса (просто endpoint /metrics)
  - Prometheus должен знать адреса всех сервисов

Push (Loki/Tempo через Alloy):
  Сервис → "вот данные" → Loki/Tempo
  + сервис сам контролирует когда отправлять
  - нужен агент (Alloy)
```

---

## Docker ports

| Сервис | Порт | Назначение |
|--------|------|------------|
| Grafana | 3000 | UI |
| Loki | 3100 | API логов |
| Tempo | 3200 | API трейсов |
| Alloy | 4317 | OTLP gRPC |
| Alloy | 4318 | OTLP HTTP |
| Alloy | 9080 | UI Alloy |
| Prometheus | 9090 | UI + API метрик |
| Keycloak | 8080 | UI + API |
| Nexus | 8081 | UI + Maven repo |
| postgres-exporter | 9187 | метрики PostgreSQL |
