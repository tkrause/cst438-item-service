require 'rails_helper'

RSpec.describe 'Items API', type: :request do

  # create some items before the tests
  let!(:items) do
    Item.create description: 'Test Item 1', price: 10.52, stockQty: 20
    Item.create description: 'Test Item 2', price: 1.15, stockQty: 10
    Item.create description: 'Test Item 3', price: 5.10, stockQty: 5
    Item.create description: 'Test Item 4', price: 2.91, stockQty: 0
  end
  let(:item_id) { Item.first.id }

  def json
    JSON.parse(response.body)
  end

  # test suite for GET /items
  describe 'GET /items' do
    before { get '/items' }

    it 'returns items' do
      expect(json).not_to be_empty
      expect(json.size).to eq 4
    end

    it 'returns status code 200' do
      expect(response).to have_http_status 200
    end
  end

  # test suite for GET /items/:id
  describe 'GET /items/:id' do
    before { get "/items/#{item_id}" }

    context 'when the record exists' do
      it 'returns the todo' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(item_id)

        item = Item.find item_id

        expect(json).to include(
            'id' => item.id,
            'description' => item.description,
            'price' => item.price.to_s,
            'stockQty' => item.stockQty,
        )
      end

      it 'returns status code 200' do
        expect(response).to have_http_status 200
      end
    end

    context 'when the record does not exist' do
      # try an item_id that doesn't exist
      let(:item_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status 404
      end

      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Item with/)
      end
    end
  end

  # test suite for POST /items
  describe 'POST /items' do
    # valid payload
    let(:valid_attributes) do
      { description: 'Post Test', price: 50.62, stockQty: 9 }
    end

    context 'when the request is valid' do
      before { post '/items', params: valid_attributes }

      it 'creates a item' do
        expect(json).to include(
            'description' => valid_attributes[:description],
            'price' => valid_attributes[:price].to_s,
            'stockQty' => valid_attributes[:stockQty]
        )
      end

      it 'returns status code 201' do
        expect(response).to have_http_status 201
      end
    end

    context 'when the request is invalid' do
      before { post '/items', params: { description: 'Foobar' } }

      it 'returns status code 400' do
        expect(response).to have_http_status 400
      end

      it 'returns a validation failure message' do
        expect(response.body)
            .to match(/Validation failed: Price can't be blank, Price is not a number/)

        expect(response.body)
            .to match(/Stockqty can't be blank, Stockqty is not a number/)
      end
    end
  end

  # Test suite for PUT /items/order
  describe 'PUT /items/order' do
    let(:valid_attributes) do
      {
          id: 1,
          itemId: item_id,
          description: 'Test Item 1',
          customerId: 1,
          price: 10.52,
          award: 0,
          total: 10.52
      }
    end

    context 'when the item exists' do
      before do
        @item = Item.find item_id
        put '/items/order', params: valid_attributes
      end

      it 'places an order' do
        expect(response.body).to be_empty
      end

      it 'decrements stock quantity' do
        stock = @item.stockQty
        item = @item.reload
        expect(item.stockQty).to eq(stock - 1)
        expect(item.stockQty).to be >= 0
      end

      it 'returns status code 204' do
        expect(response).to have_http_status 204
      end
    end

    context 'when the item does not exist' do
      before { put '/items/order', params: { itemId: 100 } }

      it 'returns status code 404' do
        expect(response).to have_http_status 404
      end

      it 'returns an error message' do
        expect(response.body).to match(/Couldn't find Item with/)
      end
    end

    context 'when the item does not have stock' do
      before do
        @item = Item.find 4
        put '/items/order', params: {itemId: 4}
      end

      it 'returns status code 400' do
        expect(response).to have_http_status 400
      end

      it 'verifies stock is unchanged' do
        stock = @item.stockQty
        item = @item.reload

        expect(stock).to eq item.stockQty
      end

      it 'returns an error message' do
        expect(response.body).to match(/Item is out of stock/)
      end
    end
  end

end