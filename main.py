from fastapi import FastAPI, Request
from fastapi.templating import Jinja2Templates
from app.database import engine, Base
from app.routers import listings, facebook
import uvicorn

# Khởi tạo cơ sở dữ liệu
Base.metadata.create_all(bind=engine)

app = FastAPI(title="FB Tool Management")

# Đăng ký các router chức năng
app.include_router(listings.router)
app.include_router(facebook.router)

# Cấu hình template giao diện
templates = Jinja2Templates(directory="app/templates")

@app.get("/")
def dashboard_view(request: Request):
    return templates.TemplateResponse(request, "dashboard.html", {})

if __name__ == "__main__":
    uvicorn.run("main:app", host="127.0.0.1", port=8000, reload=True)