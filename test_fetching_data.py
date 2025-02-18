import dash
from dash import Dash, html, dcc, Input, Output, State
import pandas as pd
import requests
from datetime import datetime, timedelta
import plotly.express as px

API_KEY = '881078-ec5446d8-7fbd-4fac-806d-8a4d81eece36'
URL = "https://api.agendor.com.br/v3/deals"

headers = {
    "Authorization": f"Token {API_KEY}",
    "Content-Type": "application/json"
}

# Função para realizar o scraping
def fetch_data():
    next_url = URL
    params = {"per_page": 100}
    all_json_deals_data = []

    while next_url:
        response = requests.get(next_url, headers=headers, params=params)
        json_deal_data = response.json().get('data', [])
        all_json_deals_data.extend(json_deal_data)
        links = response.json().get('links', {})
        next_url = links.get('next', False)

    return all_json_deals_data

# Função para processar os dados
def process_data(deals):
    deal_by_stage = {
        'stage_detail': [], 'stage_name': [], 'stage_number': [], 'stage_status': [],
        'person': [], 'title': [], 'date_created': [], 'date_lost': [], 'date_won': [],
        'organization': [], 'description': [], 'loss_reason': []
    }

    for deal in deals:
        deal_by_stage['stage_detail'].append(deal['dealStage']['name'])
        deal_by_stage['stage_number'].append(int(deal['dealStage']['sequence']))
        deal_by_stage['stage_name'].append(deal['dealStage']['funnel']['name'])
        deal_by_stage['stage_status'].append(deal['dealStatus']['name'])
        if deal['lossReason']:
            deal_by_stage['loss_reason'].append(deal['lossReason']['name'])
        else:
            deal_by_stage['loss_reason'].append(None)
        
        if deal['person']:
            deal_by_stage['person'].append(deal.get('person', {}).get('id'))
        else:
            deal_by_stage['person'].append(None)
        if deal['organization']:
            deal_by_stage['organization'].append(deal.get('organization', {}).get('id'))
        else: 
            deal_by_stage['organization'].append(None)
        deal_by_stage['date_created'].append(deal['createdAt'])
        deal_by_stage['date_won'].append(deal['wonAt'])
        deal_by_stage['date_lost'].append(deal['lostAt'])
        deal_by_stage['title'].append(deal['title'])
        deal_by_stage['description'].append(deal['description'])

    df = pd.DataFrame(deal_by_stage)
    # Supondo que df já esteja carregado
    # Criar as colunas 'id' e 'type'
    df['id'] = df['person'].fillna(df['organization'])
    df['type'] = df['person'].apply(lambda x: 'person' if pd.notna(x) else 'organization')

    # Remover as colunas 'person' e 'organization'
    df = df.drop(columns=['person', 'organization'])

    # Remover números no início da coluna 'stage_name'
    df['stage_name'] = df['stage_name'].str.replace(r'^\d+\s*', '', regex=True)

    # Filtragem por data
    df['date_created'] = pd.to_datetime(df['date_created']).dt.date

    return df

def process_line_data(df):
    # Transformação da coluna 'stage_detail'
    df['stage_detail'] = df['stage_detail'].replace({
        'CONTATO': '1.1 LEADS',
        'TYPEFORM': '2.1 VALIDAÇÃO',
        'CONTRATO': '3.1 ATIVOS'
    })
    
    return df
    

def process_bar_data(df):
    df_filtered = df[(df['stage_name'] == 'AMBULANTE ESSENCIAL') | df['description'].str.contains("CA", na=False)]


    dt_filtered = df_filtered.loc[df_filtered.groupby('id')['date_created'].idxmax()]
    df_filtered = df.dropna(subset=['id'])

    dt_filtered = dt_filtered[~dt_filtered['stage_detail'].str.contains('1', na=False)]
    d = dt_filtered['stage_detail'].value_counts()

    df_bar = d.reset_index()
    df_bar.columns = ['stage_detail', 'count']
    
    return df_bar


# Buscar os dados **apenas uma vez** ao iniciar o servidor
deals = fetch_data()
df = process_data(deals)
df.to_csv('deals_to_stage.csv')